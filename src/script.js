import './style.css'
import fragmentShader from './shaders/fragment.glsl'
import GlslCanvas from 'glslCanvas'
import * as dat from 'dat.gui'

import guy from '../static/images/guy_profile.jpeg'

const params = {
	blocks: 12.0,
	texture: guy,
	timeIntensity: 0.2,
}

function debounce(func, wait, immediate) {
	var timeout

	return function executedFunction() {
		var context = this
		var args = arguments

		var later = function () {
			timeout = null
			if (!immediate) func.apply(context, args)
		}

		var callNow = immediate && !timeout

		clearTimeout(timeout)

		timeout = setTimeout(later, wait)

		if (callNow) func.apply(context, args)
	}
}

const getTextureResolution = dataURL =>
	new Promise(resolve => {
		const img = new Image()
		img.onload = () => {
			resolve({
				x: img.width,
				y: img.height,
			})
		}
		img.src = dataURL
	})

const canvas = document.querySelector('canvas')
const sandbox = new GlslCanvas(canvas)

const initCanvas = async () => {
	sandbox.load(fragmentShader)
	const textureResolution = await getTextureResolution(params.texture)
	sandbox.setUniform('u_texture', params.texture)
	sandbox.setUniform('u_textureResolution', [
		textureResolution.x,
		textureResolution.y,
	])
	sandbox.setUniform('u_blocks', params.blocks)
	sandbox.setUniform('u_timeIntensity', params.timeIntensity)
}

initCanvas()

const updateCanvas = debounce(initCanvas, 300)

if (window.location.hash === '#debug') {
	const gui = new dat.GUI()

	gui.add(params, 'blocks', 1, 100, 1).onChange(() => updateCanvas())
	gui.add(params, 'timeIntensity', 0, 10).onChange(() => updateCanvas())
}
