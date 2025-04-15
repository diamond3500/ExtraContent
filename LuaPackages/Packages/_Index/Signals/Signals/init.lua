local Signals = require(script.Signals)

export type getter<T> = Signals.getter<T>
export type setter<T> = Signals.setter<T>
export type update<T> = Signals.update<T>
export type dispose = Signals.dispose

export type scope = Signals.scope

return {
	createSignal = Signals.createSignal,
	createComputed = Signals.createComputed,
	createEffect = Signals.createEffect,
}
