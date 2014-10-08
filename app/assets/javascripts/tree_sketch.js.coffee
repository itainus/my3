# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
angular.module('Mytree.treeSketch', ['ngResource'])
  .factory 'TreeSketch', ($http, $q) ->

    canvas = 0
    tipCanvas = 0
    ctx = 0
    W = 0
    H = 0
#    divergence = 0
    reduction = 0
    leaf_radius = 0

    start_points = []
    m_branches = {}
    m_leafs = {}
    t = {}

    drawTree: (tree) ->
      console.log ("drawing tree...")
      console.log 'tree', tree

      t = this
      m_branches = {}
      m_leafs = {}
      t.filter = tree.filter
      branches = tree.branches

      canvas = document.getElementById("tree-canvas");
      tipCanvas = document.getElementById("tip-canvas");

      $('#tree-canvas').unbind('mousemove');
      $('#tree-canvas').bind('mousemove', t.onCanvasHover);
      $('#tip-canvas').unbind('click');
      $('#tip-canvas').bind('click', t.onCanvasClick);
      $('#tip-canvas').hide()

      ctx = canvas.getContext("2d");
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = "transparent";
      ctx.fillRect(0, 0, W, H);

      W = canvas.width; #window.innerWidth;
      H = canvas.height;#400; #window.innerHeight;

      m_leafs = {}
      m_branches = {}

      for b in branches
        if (!t.filter)
          b.keep = false
        m_branches[b.id] = b
      console.log('m_branches', m_branches)

      return t.init(tree.trunk)

    init: (trunk) ->
      console.log 'trunk', trunk

#      length = 100 + Math.round(Math.random()*50);
#      length = 250;

#      divergence = 10 + Math.round(Math.random()*50);
      reduction = Math.round(50 + Math.random()*20)/100;
    
      line_width = 10;
      leaf_radius = 5;

      ctx.fillStyle = 'brown';
      ctx.strokeStyle = "brown";
      ctx.lineWidth = line_width;

      #empty the start points on every init();
      start_points = [];

      trunk_min_length = 200
      trunk_length = trunk_min_length

      sp = {x: W/2, y: 50}
      ep = t.get_endpoint(sp.x, sp.y, trunk.angle, trunk_length);

      ep.id = trunk.id;

      trunk.keep = true
      trunk.min_length = trunk_min_length
      trunk.length = trunk_length
      trunk.width = line_width
      trunk.spX = sp.x
      trunk.spY = H - sp.y
      trunk.epX = ep.x
      trunk.epY = H - ep.y

      ctx.beginPath();
      ctx.moveTo(sp.x, H - sp.y);
      ctx.lineTo(ep.x, H - ep.y);
      ctx.stroke();

      t.leafs(trunk)

      start_points.push(ep);
      return t.branches();

    branches: () ->
      new_start_points = [];

      for sp in start_points
        parent_branch = m_branches[sp.id]

        if !parent_branch
          continue

        line_width = parent_branch.width * reduction;

        ctx.beginPath();
        ctx.fillStyle = 'brown';
        ctx.strokeStyle = "brown";
        ctx.lineWidth = line_width;

        branches = parent_branch.branches
        t.sort_branches(branches)

        i = 1
        for b in branches
          branch = m_branches[b.id]
          only_leafs = (branch.branches.length == 0)

          branch_min_length = parent_branch.min_length * reduction
          branch_length = branch_min_length + (branch.leafs.length * (!only_leafs) * 10);
          branch_width = line_width * Math.round(50 + Math.random() * 20) / 100;
          angle = Math.round((180 / (branches.length + 1)) * (i++) + ((Math.random() * 10) - 5))
          if (branches.length == 1)
            angle = if parent_branch.angle < 90 then 75 else 105
          if angle < 95 && angle > 85
            angle = if angle < 90 then 85 else 95

          ep = t.get_endpoint(sp.x, sp.y, angle, branch_length);
          ep.id = branch.id

          branch.min_length = branch_min_length;
          branch.length = branch_length;
          branch.width = branch_width
          branch.angle = angle
          branch.spX = sp.x
          branch.spY = H - sp.y
          branch.epX = ep.x
          branch.epY = H - ep.y

          console.log 'branch', branch.id , branch.category.name + ' - angle = ' + branch.angle + ' - width = ' + branch.width + ' - from ('  + branch.spX + ',' + branch.spY  + ') to (' + branch.epX + ',' + branch.epY+')'

          if (!t.filter || branch.keep)
            branch.keep = true
            ctx.lineWidth = branch_width;
            ctx.moveTo(sp.x, H - sp.y);
            ctx.lineTo(ep.x, H - ep.y);
            ctx.stroke();
            t.leafs(branch)

          new_start_points.push(ep);

      ctx.stroke();

      start_points = new_start_points;

      if (new_start_points.length)
        setTimeout(t.branches, 50);
      return

    leafs: (branch) ->
      j = 0
      leafs = branch.leafs
      no_branches = (branch.branches.length == 0)

      if !leafs
        return

      for leaf in leafs
        j++
        branch_exit_point = if no_branches then branch.length else (branch.length / (leafs.length + 1) * j)
        leaf_length = branch.min_length * 0.5
        leaf_length = branch.length * 0.25
        leaf_angle = if no_branches then (Math.round((180 / (leafs.length + 1)) * j + ((Math.random() * 10) - 5))) else if j%2 then branch.angle - 30 else branch.angle + 30
        leaf_sp = t.get_endpoint(branch.spX, H - branch.spY, branch.angle, branch_exit_point)
        leaf_ep = t.get_endpoint(leaf_sp.x, leaf_sp.y, leaf_angle, leaf_length)

        leaf.sp = leaf_sp
        leaf.ep = leaf_ep

        console.log 'leaf', leaf.id , leaf.name + ' - angle = ' + leaf_angle + ' - from ('  + leaf.sp.x + ',' + (H - leaf.sp.y)  + ') to (' + leaf.ep.x + ',' + (H - leaf.ep.y) + ')'

        if (!t.filter || leaf.keep)
          leaf.keep = true
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

    sort_branches: (branches) ->
      branches.sort (a,b) ->
        aBranch = m_branches[a.id]
        bBranch = m_branches[b.id]
        return (aBranch.branches.length + aBranch.leafs.length) - (bBranch.branches.length + bBranch.leafs.length)

      for i in [0...branches.length / 2] by 2
        j = branches.length - 1 - i
        tmp = branches[i]
        branches[i] = branches[j]
        branches[j] = tmp
      return branches

    get_endpoint: (x, y, a, len) ->
      epx = x + len * Math.cos(a*Math.PI/180);
      epy = y + len * Math.sin(a*Math.PI/180);
      return {x: epx, y: epy};

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
      $("#tip-canvas").tooltip('hide').attr('data-original-title', msg).tooltip('show');

      $('#tip-canvas').fadeIn()
      $('#tip-canvas').removeClass('open')

    getLeafByPoint: (x, y) ->
      for k,l of m_leafs
        if (!l.keep)
          continue
        dx = x - l.ep.x
        dy = y - (H - l.ep.y)
        if (dx * dx + dy * dy <= leaf_radius * leaf_radius)
          return l
      return null

    getBranchByPoint: (x, y) ->
      for k,b of m_branches
        if (!b.keep)
          continue
        spx = b.spX;
        spy = b.spY
        epx = b.epX
        epy = b.epY
#
#        if b.category.id == 1
#          continue

        if ((y > spy) || (y < epy))
          continue

        x1 = epx
        y1 = epy
        x2 = spx
        y2 = spy
        A = (y1 - y2) / (x1 - x2);
        B = y1 - (A * x1)

        res = A * x + B - y

        if Math.ceil(b.width) >= Math.abs(res)
#        if w >= Math.abs(res)
#          console.log(b.category.name, x, y)
          return b

      return null

    onCanvasClick: (e) ->
      pt = t.getMouse(e, canvas);
      name = ''
      id = 0;
      type = ''
      showMenu = false

      e.stopPropagation()

#      console.log 'leaf-click', pt.x, pt.y
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
#        console.log('point clicked = (' + pt.x + ',' + pt.y + ')')
        b = t.getBranchByPoint(pt.x, pt.y)
        if b
          $('#tree-canvas-stats-goto').hide()
          $('#tree-canvas-stats-zoom').show()
          name = b.category.name
          id = b.id
          type = 'branch'
          showMenu = true

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