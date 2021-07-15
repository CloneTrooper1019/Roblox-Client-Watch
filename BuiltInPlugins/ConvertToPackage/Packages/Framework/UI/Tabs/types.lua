local Framework = script.Parent.Parent.Parent
local Types = require(Framework.Types)

export type Props = {
	SelectedTab: Tab,
	OnTabSelected: (Tab) -> (),
	TabComponent: Types.RoactComponent<TabProps>?,
	Tabs: Types.Array<Tab>,
	Style: string?
}

export type ConnectedProps = Props & {
	Stylizer: TabsStyle,
}

export type Tab = {
	Label: string?,
	Icon: string?,
	Tooltip: string?,
	Disabled: boolean?
}

export type TabProps = {
	Tab: Tab,
	Selected: boolean,
	Disabled: boolean,
	Index: number,
	OnTabSelected: (Tab) -> (),
	Style: TabsStyle
}

export type ConnectedTabProps = TabProps & {
	AbsoluteSize: Vector2,
	StyleModifier: Types.StyleModifier?,
	WrapperProps: Types.WrapperProps,
}

export type TabsStyle = {
	BorderSize: number,
	Spacing: number,
	Padding: Types.Padding,
	TopLineHeight: number,
	Color: Color3,
	HoverColor: Color3,
	BackgroundColor: Color3,
	SelectedBackgroundColor: Color3,
	DisabledColor: Color3,
	BorderColor: Color3,
}

return nil
