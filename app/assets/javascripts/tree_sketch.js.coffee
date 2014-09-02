# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
angular.module('Mytree.treeSketch', ['ngResource'])
  .factory 'TreeSketch', ($http, $q) ->

    canvas = 0
    tipCanvas = 0
    ctx = 0
    tipCtx = 0
    canvas = 0
    W = 0
    H = 0
    length = 0
    divergence = 0
    reduction = 0
    line_width = 0
    start_points = [];
    t = 0
    radius = 5
    m_children = []
    m_categories = [];
    m_links = [];


    getMouse: (e, c) ->
      element = c
      offsetX = 0
      offsetY = 0

#    // Compute the total offset. It's possible to cache this if you want
      if (element.offsetParent != undefined)
        offsetY += element.offsetTop
        offsetX += element.offsetLeft

        while (element = element.offsetParent)
          offsetY += element.offsetTop
          offsetX += element.offsetLeft

#is part is not strictly necessary, it depends on your styling
#    offsetX += stylePaddingLeft + styleBorderLeft + htmlLeft;
#    offsetY += stylePaddingTop + styleBorderTop + htmlTop;

      mx = e.pageX - offsetX;
      my = e.pageY - offsetY;

      return {x: mx, y: my}

    showTooltip: (x, y, msg) ->
      tipCanvas.style.left = (x) + "px";
      tipCanvas.style.top = (y) + "px";
      tipCtx.clearRect(0, 0, tipCanvas.width, tipCanvas.height);
      tipCtx.fillText(msg, 5, 15);
      $('#tip-canvas').fadeIn()

    getCategoryByPoint: (x, y) ->
      for c in m_categories
        spx = c.spX;
        spy = c.spY
        epx = c.epX
        epy = c.epY

        if c.id == 1
          continue

        if ((y > spy) || (y < epy))
          continue

        x1 = epx
        y1 = epy
        x2 = spx
        y2 = spy
        a = (y1 - y2) / (x1 - x2);
        b = y1 - (a * x1)

        console.log(x1, x, x2);

        res = a * x + b - y

        if c.width >= Math.abs(res)
          return c

      return null

    onCanvasHover: (e) ->
      pt = t.getMouse(e, canvas);

      for l in m_links
        dx = pt.x - l.x
        dy = pt.y - l.y
        if (dx * dx + dy * dy <= radius * radius)
#          console.log l
          t.showTooltip(l.x + 15, l.y - 30, '[' + l.id + '] ' + l.name)
          return

      c = t.getCategoryByPoint(pt.x, pt.y)
      if c
        t.showTooltip(pt.x, pt.y, '[' + c.id + '] ' + c.name)
        return

      $('#tip-canvas').fadeOut()


    drawTree: (branches, leafs) ->
      console.log "drawing tree..."

      t = this
      canvas = document.getElementById("tree-canvas");
      tipCanvas = document.getElementById("tip-canvas");

      $('#tree-canvas').unbind('mousemove');
      $('#tree-canvas').bind('mousemove', t.onCanvasHover);

      $('#tree-canvas').unbind('click');
      $('#tree-canvas').bind('click', t.onCanvasClick);

      $('#tip-canvas').hide()

      ctx = canvas.getContext("2d");
      tipCtx = tipCanvas.getContext("2d");
      #Lets resize the canvas to occupy the full page
      W = canvas.width; #window.innerWidth;
      H = 400; #window.innerHeight;
#      W = canvas.width #window.innerWidth;
#      H = canvas.height #window.innerHeight;

      canvas.width = W;
      canvas.height = H;

      m_children = []
      m_links = []
      m_categories = []

      for b in branches
        m_categories.push(b.category)
        b.category.id *= 1
        b.category.category_id *= 1

        if (b.category.id == 1)
          continue
        if (m_children[b.category.category_id])
          m_children[b.category.category_id] += 1
        else
          m_children[b.category.category_id] = 1

      for l in leafs
        l.link.name = l.name
        m_links.push(l.link)
        l.link.id *= 1
        l.link.category_id *= 1
        if (m_children[l.link.category_id])
          m_children[l.link.category_id] += 1
        else
          m_children[l.link.category_id] = 1

#      m_categories = categories
#      m_links = links;

      t.init()

    init: () ->
      #filling the canvas white
      ctx.fillStyle = "transparent";
      ctx.fillRect(0, 0, W, H);


      length = 100 + Math.round(Math.random()*50);
      console.log('tree first len:', length);
      #angle at which branches will diverge - 10-60
      divergence = 10 + Math.round(Math.random()*50);
      #Every branch will be 0.75times of the previous one - 0.5-0.75
      #with 2 decimal points
      reduction = Math.round(50 + Math.random()*20)/100;
      #width of the branch/trunk
      line_width = 10;

#This is the end point of the trunk, from where branches will diverge
      trunk = {x: W/2, y: length+50, angle: 90, id: 1, parentID: 1};
#It becomes the start point for branches
      start_points = []; #empty the start points on every init();
      start_points.push(trunk);

#Y coordinates go positive downwards, hence they are inverted by deducting it
#from the canvas height = H
      ctx.beginPath();
      ctx.moveTo(trunk.x, H-50);
      ctx.lineTo(trunk.x, H-trunk.y);
      ctx.strokeStyle = "brown";
      ctx.lineWidth = line_width;
      ctx.stroke();

      t.branches();


    #Lets draw the branches now
    branches: () ->

      #reducing line_width and length
      length = length * reduction;
      line_width = line_width * reduction;
      ctx.lineWidth = line_width;

      new_start_points = [];
#      ctx.beginPath();

      #for(i = 0; i < start_points.length; i++)
        #sp = start_points[i];
      for sp in start_points

        i = 1
        ctx.beginPath();
        ctx.strokeStyle = "brown";

        nBranches = m_children[sp.id]

        for c in m_categories
          if c.category_id == sp.id && c.id != sp.id

            angle = Math.round((180 / (nBranches + 1)) * i + ((Math.random() * 10) - 5))

            i++

            ep = t.get_endpoint(sp.x, sp.y, angle, length);
            ep.id = c.id

            ctx.lineWidth = line_width * Math.round(50 + Math.random()*20)/100;

            c.len = length;
            c.width = line_width
            c.angle = angle
            c.spX = sp.x
            c.spY = H-sp.y
            c.epX = ep.x
            c.epY = H-ep.y
#            c.xDirection = c.epX - c.spX


            ctx.moveTo(sp.x, H-sp.y);
            ctx.lineTo(ep.x, H-ep.y);

            ctx.stroke();

            new_start_points.push(ep);


        ctx.stroke();

        for l in m_links
          if l.category_id == sp.id

            ctx.beginPath();
            ctx.fillStyle = 'lightgreen';
            ctx.strokeStyle = "green";
            ctx.lineWidth = 1

            angle = Math.round((180 / (nBranches + 1)) * i + 0*((Math.random() * 10) - 5))
            i++

            ep = t.get_endpoint(sp.x, sp.y, angle, length);
            ctx.moveTo(sp.x, H-sp.y);
            ctx.lineTo(ep.x, H-ep.y);

            l.x = ep.x
            l.y = H-ep.y

            ctx.stroke();
            ctx.beginPath();

            centerX = ep.x
            centerY = H - ep.y

            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
            ctx.fill();
            ctx.stroke();

      start_points = new_start_points;

      if (new_start_points.length)
        setTimeout(t.branches, 50);
      else
        #setTimeout(t.init, 500);

    get_endpoint: (x, y, a, length) ->

      epx = x + length * Math.cos(a*Math.PI/180);
      epy = y + length * Math.sin(a*Math.PI/180);

      return {x: epx, y: epy};
