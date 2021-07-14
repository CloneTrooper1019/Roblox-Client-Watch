--[[
	Types which are used across all of DevFramework and can also be used by any built-in plugins.

	Currently you can't export Luau types, so you must require this file directly to access
	the types i.e. local Types = require(Framework.Types) where Framework is the root ModuleScript
	(rather than a table)
]]

-- TODO #luau: support these internally
export type Array<T> = {[number]: T}
export type Record<K, V> = {[K]: V}
export type AnyRecord = Record<any, any>

-- TODO #lua-foundation: types for Roact & Rodux
export type Roact = any
export type RoactComponent<T> = any
export type RoactElement = any
export type RoduxStore = any

-- Style types
export type Padding = number | {
	Left: number?,
	Top: number?,
	Bottom: number?,
	Right: number?,
}

-- Additional props from wrappers can be any valid prop
export type WrapperProps = {
	[string]: any
}

-- TODO #lua-foundation: Types for symbols
export type StyleModifier = any

return nil
