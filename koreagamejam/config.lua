--
-- For more information on config.lua see the Corona SDK Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 1920,
		height = 1080,
		scale = "letterBox",
		fps = 30,
	},
	window =
	{
		defaultViewWidth = 1280,
		defaultViewWidth = 720,
		resizable = true,
		minViewWidth = 1920,
		minViewHeight = 1080,
		enableCloseButton = true,
		enableMinimizeButton = true,
		enableMaximizeButton = true,
		suspendWhenMinimized = true,
		titleText =
		{
			default = "untitled"
		},
	},
}
