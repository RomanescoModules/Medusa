class Medusa extends g.RShape
	@Shape = paper.Path.Rectangle
	@rname = 'Medusa'
	@rdescription = "Creates a bunch of aniamted Medusa."
	@squareByDefault = true

	@parameters: ()->
		parameters = super()

		parameters['Parameters'] ?= {}
		parameters['Parameters'].stripeWidth =
			type: 'slider'
			label: 'Stripe width'
			min: 1
			max: 5
			default: 1
		parameters['Parameters'].maskWidth =
			type: 'slider'
			label: 'Mask width'
			min: 1
			max: 4
			default: 1
		parameters['Parameters'].speed =
			type: 'slider'
			label: 'Speed'
			min: 0.01
			max: 1.0
			default: 0.1

		return parameters

	# animted paths must be initialized
	initialize: ()->
		@data.animate = true
		@setAnimated(@data.animate)
		return

	createShape: ()->
		@data.nTentacles
		@data.nSegments
		@data.pulsePeriod
		@data.elasticConstant

		@path = @addPath()
		topSegment = new Segment(@rectangle.center.x, @rectangle.top)
		topSegment.handleIn = new Point(-@rectangle.width/3, 0)
		topSegment.handleOut =  new Point(@rectangle.width/3, 0)
		@path.add(topSegment)

		@leftSegment = new Segment(@rectangle.left, @rectangle.top+@rectangle.height*0.7)
		@leftSegment.handleIn = new Point(0, -@rectangle.height*0.5)
		@leftSegment.handleOut =  new Point(0, @rectangle.height*0.3)
		@path.add(@leftSegment)

		@rightSegment = new Segment(@rectangle.right, @rectangle.top+@rectangle.height*0.7)
		@rightSegment.handleIn = new Point(0, -@rectangle.height*0.5)
		@rightSegment.handleOut =  new Point(0, @rectangle.height*0.3)
		@path.add(@rightSegment)

		position = @leftSegment.location.offset
		step = (@rightSegment.location.offset - @leftSegment.location.offset) / nTentacles

		@tentacles = []
		for i in [0 .. nTentacles]
			console.log "draw tentacle"
			point = @path.getPointAt(position)
			normal = @path.getNormalAt(position)
			tentacle = @addPath()
			tentacle.add(point)
			for j in [0 .. nSegments]
				tentacle.add(point.add(normal.multiply(j)))
			@tentacles.push(tentacle)
			position += step

		return

	onFrame: (event)=>
		# check if event gives time
		direction = new Point(1, 0)
		direction.angle = @rotation
		normal = direction.clone()
		normal.angle += 90

		force = null
		time = Date.now()
		if time > @lastUpdate + @data.pulsePeriod
			@lastUpdate = time
			force = normal.multiply(@data.pulseAmplitude)
		else
			force = normal.multiply(-0.1*@data.pulseAmplitude)

		@leftSegment.point = @leftSegment.point.add(force)
		@rightSegment.point = @rightSegment.point.subtract(force)

		position = @leftSegment.location.offset
		step = (@rightSegment.location.offset - @leftSegment.location.offset) / nTentacles

		for tentacle in @tentacles
			lastPoint = @path.getPointAt(position)
			for segment in tentacle.segments
				delta = lastPoint.subtract(segment.point)
				segment.point.translate(delta.multiply(@data.elasticConstant))
				lastPoint = segment.point

			position += step

		return

tool = new g.PathTool(Medusa, true)