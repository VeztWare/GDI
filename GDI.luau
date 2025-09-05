local GDI = {}
GDI.Rendering = {}

function GDI.Rendering.InterpolateEdge(y: number, vStart: Vector2, vEnd: Vector2)
	if vStart.Y == vEnd.Y then
		return vStart.X
	end
	return vStart.X + (y - vStart.Y) * (vEnd.X - vStart.X) / (vEnd.Y - vStart.Y)
end

function GDI.ReverseColor(color, type)
	if type == "RGB" then
		local r, g, b = table.unpack(color)
		return Color3.fromRGB(255 - r, 255 - g, 255 - b)
	elseif type == "HSV" then
		local h, s, v = table.unpack(color)
		return Color3.fromHSV(h, s, 1 - v)
	elseif type == "Hex" then
		local r = tonumber(color:sub(2,3),16)
		local g = tonumber(color:sub(4,5),16)
		local b = tonumber(color:sub(6,7),16)
		r, g, b = 255 - r, 255 - g, 255 - b
		return string.format("#%02X%02X%02X", r, g, b)
	end
end

function GDI.ReversePosition(obj)
	return obj:IsA("GuiObject") and {0, -obj.Position.X.Offset, 0, -obj.Position.Y.Offset} or {-obj.Position.X, -obj.Position.Y, -obj.Position.Z}
end

function GDI.DrawTriangle(parent: Instance, a: Vector2, b: Vector2, c: Vector2, color: Color3, position: Vector2?)
	position = position or Vector2.new(0, 0)

	local A = a + position
	local B = b + position
	local C = c + position

	local vertices = {A, B, C}
	table.sort(vertices, function(v1, v2) return v1.Y < v2.Y end)
	local top, middle, bottom = unpack(vertices)

	for y = math.floor(top.Y), math.ceil(bottom.Y) do
		local xStart, xEnd
		if y < middle.Y then
			xStart = GDI.Rendering.InterpolateEdge(y, top, middle)
			xEnd = GDI.Rendering.InterpolateEdge(y, top, bottom)
		else
			xStart = GDI.Rendering.InterpolateEdge(y, middle, bottom)
			xEnd = GDI.Rendering.InterpolateEdge(y, top, bottom)
		end
		if xStart > xEnd then xStart, xEnd = xEnd, xStart end

		local strip = Instance.new("Frame")
		strip.BorderSizePixel = 0
		strip.BackgroundColor3 = color
		strip.Position = UDim2.fromOffset(xStart, y)
		strip.Size = UDim2.fromOffset(xEnd - xStart, 1)
		strip.Parent = parent
	end
end

function GDI.DrawCircle(parent: Instance, center: Vector2, radius: number, color: Color3)
	local r2 = radius * radius
	local startY = math.floor(center.Y - radius)
	local endY = math.ceil(center.Y + radius)

	for y = startY, endY do
		local dy = y - center.Y
		local dx = math.sqrt(math.max(0, r2 - dy*dy))

		local xStart = center.X - dx
		local xEnd = center.X + dx

		local strip = Instance.new("Frame")
		strip.BorderSizePixel = 0
		strip.BackgroundColor3 = color
		strip.Position = UDim2.fromOffset(xStart, y)
		strip.Size = UDim2.fromOffset(xEnd - xStart, 1)
		strip.Parent = parent
	end
end


return GDI
