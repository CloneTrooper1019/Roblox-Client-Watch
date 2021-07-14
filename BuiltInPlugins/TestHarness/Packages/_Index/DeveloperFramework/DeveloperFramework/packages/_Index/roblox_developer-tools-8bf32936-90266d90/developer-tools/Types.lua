export type BridgeMessage = {
	eventName: string;
	fromBridgeId: string?;
	fromTargetId: string?;
	toBridgeId: string?;
	toTargetId: string?;
}

export type BridgeListener = {
	eventName: string?;
	bridgeId: string?;
	targetId: string?;
	onEvent: (BridgeMessage) -> ();
}