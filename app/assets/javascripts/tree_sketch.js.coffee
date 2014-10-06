# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
angular.module('Mytree.treeSketch', ['ngResource'])
  .factory 'TreeSketch', ($http, $q) ->

    canvas = 0
    tipCanvas = 0
    ctx = 0
    canvas = 0
    W = 0
    H = 0
    length = 0
    divergence = 0
    reduction = 0
    line_width = 0
    start_points = []
    t = 0
    radius = 5
    m_children = []
    m_branches = {}
    m_leafs = {}


    getMouse: (e, c) ->
      element = c
      offsetX = 0
      offsetY = 0

      if (element.offsetParent != undefined)
        offsetY += element.offsetTop
        offsetX += element.offsetLeft

        while (element = element.offsetParent)
          offsetY += element.offsetTop
          offsetX += element.offsetLeft

      mx = e.pageX - offsetX;
      my = e.pageY - offsetY;

      return {x: mx, y: my}

    showTooltip: (x, y, msg) ->
      tipCanvas.style.left = (x) + "px";
      tipCanvas.style.top = (y) + "px";
#      tipCanvas.title = msg
      $("#tip-canvas").tooltip('hide').attr('data-original-title', msg).tooltip('show');

      $('#tip-canvas').fadeIn()
      $('#tip-canvas').removeClass('open')

    getLeafByPoint: (x, y) ->
      for k,l of m_leafs
        dx = x - l.ep.x
        dy = y - (H - l.ep.y)
        if (dx * dx + dy * dy <= radius * radius)
          return l
      return null

    getBranchByPoint: (x, y) ->
#      for b in m_branches
      for k,b of m_branches
        spx = b.spX;
        spy = b.spY
        epx = b.epX
        epy = b.epY

        if b.category.id == 1
          continue

        if ((y > spy) || (y < epy))
          continue

        x1 = epx
        y1 = epy
        x2 = spx
        y2 = spy
        A = (y1 - y2) / (x1 - x2);
        B = y1 - (A * x1)

#        console.log(x1, x, x2);

        res = A * x + B - y
#
#        if (b.angle > 90)
#          beta = b.angle - 90
#        else
#          beta = 90 - b.angle
#
#        w = b.width / Math.cos(beta)

        if Math.ceil(b.width) >= Math.abs(res)
#        if w >= Math.abs(res)
          console.log(b.category.name, x, y)
          return b

      return null

    onCanvasClick: (e) ->
      pt = t.getMouse(e, canvas);
      name = ''
      id = 0;
      type = ''
      showMenu = false

      e.stopPropagation()

      console.log 'leaf-click', pt.x, pt.y
      l = t.getLeafByPoint(pt.x, pt.y)

      if l
        $('#tree-canvas-stats-zoom').hide()
        name = l.name
        id = l.id
        type = 'leaf'
        $('#tree-canvas-stats-goto').attr("href", l.link.url);
        $('#tree-canvas-stats-goto').show()
        showMenu = true

      else
        console.log('point clicked = (' + pt.x + ',' + pt.y + ')')
        b = t.getBranchByPoint(pt.x, pt.y)
        if b
          $('#tree-canvas-stats-goto').hide()
          $('#tree-canvas-stats-zoom').show()
          name = b.category.name
          id = b.id
          type = 'branch'
          showMenu = true

#      $('#tree-canvas-stats-menu').html('</i><i class="fa ' + icon + '"></i><b style="margin-left: 5px;"><i>' + name + '</i></b>')


      if showMenu #|| e.currentTarget.id == "tip-canvas"
        $('#tip-canvas').addClass('open')
        $('#tree-canvas-stats-menu').attr('data-stats-type', type)
        $('#tree-canvas-stats-menu').attr('data-stats-id', id)
      return

    onCanvasHover: (e) ->
      pt = t.getMouse(e, canvas);
      l = t.getLeafByPoint(pt.x, pt.y)
      if l
        t.showTooltip(l.ep.x + 8, H - l.ep.y - 7, '[' + l.id + '][' + l.link.id + '] ' + l.name)
        return

      b = t.getBranchByPoint(pt.x, pt.y)
      if b
        t.showTooltip(pt.x, pt.y - 7, '[' + b.id + '][' + b.category.id + '] ' + b.category.name)
        return

      $('#tip-canvas').fadeOut()
      return


    drawTree: (tree) ->
      console.log ("drawing tree...")
      console.log tree

      branches = tree.branches
      leafs = tree.leafs
      t.filter = tree.filter


      t = this
#      t.filter = !!filter
      canvas = document.getElementById("tree-canvas");
      tipCanvas = document.getElementById("tip-canvas");

      $('#tree-canvas').unbind('mousemove');
      $('#tree-canvas').bind('mousemove', t.onCanvasHover);

      $('#tip-canvas').unbind('click');
      $('#tip-canvas').bind('click', t.onCanvasClick);

      $('#tip-canvas').hide()

      ctx = canvas.getContext("2d");
      #Lets resize the canvas to occupy the full page
      W = canvas.width; #window.innerWidth;
      H = canvas.height;#400; #window.innerHeight;

      canvas.width = W;
      canvas.height = H;

      m_children = []
      m_leafs = {}
      m_links = []
      m_branches = {}
      m_categories = []


      for b in branches
#        m_branches.push(b)
        m_branches[b.id] = b
#        b.category.id *= 1
#        b.category.category_id *= 1
#
#        if (!b.category.category_id)
#          continue

#        if (m_children[b.category.category_id])
#          m_children[b.category.category_id] += 1
#        else
#          m_children[b.category.category_id] = 1
#
#      for l in leafs
#        m_leafs.push(l)
#        l.link.id *= 1
#        l.link.category_id *= 1
#        if (m_children[l.link.category_id])
#          m_children[l.link.category_id] += 1
#        else
#          m_children[l.link.category_id] = 1

      trunk = {x: W/2, y: 200, angle: 180 - tree.root_angle, id: tree.root_category_id};

#      m_branches[trunk.id] = trunk

      console.log(m_branches)

      t.init(trunk)

    init: (trunk) ->
      #filling the canvas white
      ctx.fillStyle = "transparent";
      ctx.fillRect(0, 0, W, H);

      length = 100 + Math.round(Math.random()*50);
      length = 250;
      #angle at which branches will diverge - 10-60
      divergence = 10 + Math.round(Math.random()*50);
      #Every branch will be 0.75times of the previous one - 0.5-0.75
      #with 2 decimal points
      reduction = Math.round(50 + Math.random()*20)/100;
      reduction = 0.6;
      #width of the branch/trunk
      line_width = 10;

      #empty the start points on every init();
      start_points = [];

      ep = t.get_endpoint(trunk.x, H-trunk.y, trunk.angle, length);

      trunk.len = length;
      trunk.width = line_width
      trunk.spX = trunk.x
      trunk.spY = H-50
      trunk.epX = ep.x
      trunk.epY = H-ep.y

      ctx.beginPath();
      ctx.moveTo(ep.x, H-50);
      ctx.lineTo(trunk.x, H-trunk.y);
      ctx.fillStyle = 'brown';
      ctx.strokeStyle = "brown";
      ctx.lineWidth = line_width;
      ctx.stroke();

      start_points.push(trunk);
      return t.branches();

    branches: () ->
      length = length * reduction;
      line_width = line_width * reduction;
      ctx.lineWidth = line_width;

      new_start_points = [];

      for sp in start_points
        i = 1
        ctx.beginPath();
        ctx.fillStyle = 'brown';
        ctx.strokeStyle = "brown";

        parent_branch = m_branches[sp.id]
        branches = parent_branch.branches
        for b in branches
          branch = m_branches[b.id]
          width = line_width * Math.round(50 + Math.random() * 20) / 100;
          angle = Math.round((180 / (branches.length + 1)) * (i++) + ((Math.random() * 10) - 5))
          if (branches.length == 1)
            angle = 75
          if angle < 95 && angle > 85
            angle = 95

          ep = t.get_endpoint(sp.x, sp.y, angle, length);
          ep.id = branch.id

          branch.len = length;
          branch.width = width
          branch.angle = angle
          branch.spX = sp.x
          branch.spY = H - sp.y
          branch.epX = ep.x
          branch.epY = H - ep.y

          console.log 'branch', branch.id , branch.category.name + ' - angle = ' + branch.angle + ' - width = ' + branch.width + ' - from ('  + branch.spX + ',' + branch.spY  + ') to (' + branch.epX + ',' + branch.epY+')'

          if (!t.filter || branch.keep)
            ctx.lineWidth = width;
            ctx.moveTo(sp.x, H - sp.y);
            ctx.lineTo(ep.x, H - ep.y);
            ctx.stroke();

            j = 0
            leafs = branch.leafs
            for leaf in leafs
              ++j
              leaf_branch_length = if branch.branches.length == 0 then length else (length / (leafs.length + 1) * j)
              leaf_length = length * 0.25
              leaf_angle = if branch.branches.length == 0 then (Math.round((180 / (leafs.length + 1)) * j + ((Math.random() * 10) - 5))) else if j%2 then branch.angle - 30 else branch.angle + 30
              leaf_sp = t.get_endpoint(sp.x, sp.y, branch.angle, leaf_branch_length)
              leaf_ep = t.get_endpoint(leaf_sp.x, leaf_sp.y, leaf_angle, leaf_length)

              leaf.sp = leaf_sp
              leaf.ep = leaf_ep

              console.log 'leaf', leaf.id , leaf.name + ' - angle = ' + leaf_angle + ' - from ('  + leaf.sp.x + ',' + (H - leaf.sp.y)  + ') to (' + leaf.ep.x + ',' + (H - leaf.ep.y) + ')'

              if (!t.filter || leaf.keep)
                m_leafs[leaf.id] = leaf
                img = new Image();
                img.src = 'http://g.etfv.co/' + leaf.link.url
                img.leaf = leaf
                img.onload = () ->
                  ctx.beginPath();
                  ctx.fillStyle = 'lightgreen';
                  ctx.strokeStyle = "green";
                  ctx.lineWidth = 1
                  ctx.moveTo(this.leaf.sp.x, H - this.leaf.sp.y);
                  ctx.lineTo(this.leaf.ep.x, H - this.leaf.ep.y);
                  ctx.drawImage(this, this.leaf.ep.x - 8, H - this.leaf.ep.y - 8, 16, 16);
                  ctx.stroke();

          new_start_points.push(ep);

      ctx.stroke();

      start_points = new_start_points;

      if (new_start_points.length)
        setTimeout(t.branches, 50);
      return

    get_endpoint: (x, y, a, length) ->
      epx = x + length * Math.cos(a*Math.PI/180);
      epy = y + length * Math.sin(a*Math.PI/180);
      return {x: epx, y: epy};