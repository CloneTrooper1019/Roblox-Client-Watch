-- TODO #luau: support these internally
export type Array<T> = {[number]: T}
export type Record<K, V> = {[K]: V}
export type AnyRecord = Record<any, any>

-- TODO #lua-foundation: types for Roact
export type Roact = any
export type RoactTree = any
export type RoactComponent = any
export type RoactInstance = any
export type RoactNode = any

export type EventName = string

export type BridgeMessage = {
	eventName: EventName,
	fromBridgeId: string?,
	fromTargetId: string?,
	toBridgeId: string?,
	toTargetId: string?,
}

export type BridgeListener = {
	eventName: EventName?,
	bridgeId: string?,
	targetId: string?,
	onEvent: (BridgeMessage) -> (),
}

export type ProfileComponentRow = {
	instanceId: number,
	count: number,
	depth: number,
	path: Types.Array<string>,
	pathString: string,
	instanceName: string,
	time: number,
	renderTime: number,
}

export type ProfileEvent = {
	instance: Types.RoactInstance,
	depth: number,
	renderTime: number,
	startTime: number,
	endTime: number,
	updateTrace: string,
	isPure: boolean,
	oldState: AnyRecord,
	newState: AnyRecord,
	oldProps: AnyRecord,
	newProps: AnyRecord,
}

export type ProfileEventInfo = {
	startTime: number,
	renderTime: number,
	time: number,
	cause: string,
	updateTrace: string,
	details: string,
	detailsTip: string,
}

export type ProfileData = {
	componentRows: Types.Array<Types.ProfileComponentRow>,
	eventRows: Types.Array<Types.ProfileEventInfo>,
	rowCount: number,
	eventCount: number,
	instanceEventCount: number,
}

return nil
