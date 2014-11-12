# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
angular.module('Mytree.treeSketch', ['ngResource'])
  .factory 'TreeSketch', ($http, $q) ->

    $scope = null
    canvas = null
    tipCanvas = null
    ctx = 0
    W = 0
    H = 0
#    divergence = 0
    reduction = 0
    leaf_radius = 0
    branch_name_padding = 0
    start_points = []
    m_branches = {}
    m_leafs = {}
    t = {}

    draw_tree: (tree, filter, scope) ->
      console.log ("drawing tree...")
      console.log 'tree', tree

      $scope = scope
      t = this

      canvas = document.getElementById("tree-canvas");
      tipCanvas = document.getElementById("tip-canvas");

      $('#tree-canvas').unbind('mousemove');
      $('#tree-canvas').bind('mousemove', t.onCanvasHover);
      $('#tree-canvas').unbind('click');
      $('#tree-canvas').bind('click', t.onCanvasClick);
      $('#tip-canvas').unbind('click');
      $('#tip-canvas').bind('click', t.onTipCanvasClick);
      $('#tip-canvas').hide()

      ctx = canvas.getContext("2d");
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.fillStyle = "transparent";
      ctx.fillRect(0, 0, W, H);

      W = canvas.width; #window.innerWidth;
      H = canvas.height;#400; #window.innerHeight;

      tree.trunk.angle = if tree.trunk.angle then tree.trunk.angle else 90
      tree.trunk.rank = 0

      t.init_branches(tree, filter)
      t.set_branches_rank(tree.trunk)
      t.set_branches_weight(tree.trunk)
#      console.log('m_branches', m_branches)

      return t.init(tree.trunk)

    init_branches: (tree, filter) ->
      m_leafs = {}
      m_branches = {}
      for b in tree.branches
        m_branches[b.id] = b
      t.keep_branch(tree.trunk, filter)
      m_branches[tree.trunk.id] = tree.trunk

    keep_branch: (trunk, filter) ->
      trunk.keep = !filter
      for leaf in trunk.leafs
        leaf.keep = !filter
        if (leaf.link.url.indexOf(filter) != -1)
          leaf.keep = true
        trunk.keep |= leaf.keep
      for b in trunk.branches
        branch = m_branches[b.id]
        branch.keep = !filter
        t.keep_branch(branch, filter)
        trunk.keep |= branch.keep
      return trunk.keep

    init: (trunk) ->
#      console.log 'trunk', trunk

#      length = 100 + Math.round(Math.random()*50);
#      length = 250;

#      divergence = 10 + Math.round(Math.random()*50);
      reduction = Math.round(50 + Math.random()*20)/100;
    
      line_width = 10;
      leaf_radius = 8;
      branch_name_padding = 5

      ctx.fillStyle = 'brown';
      ctx.strokeStyle = "brown";
      ctx.lineWidth = line_width;

      #empty the start points on every init();
      start_points = [];

      if !trunk.min_length
        trunk.min_length = 0

      if !trunk.length
        trunk.length = 0
        trunk.reduction = 1

      trunk_min_length = Math.max(trunk.min_length, 200)
      trunk_length = Math.max(trunk.length / trunk.reduction, trunk_min_length)

      sp = {x: W/2, y: 20}
      ep = t.get_endpoint(sp.x, sp.y, trunk.angle, trunk_length);

      ep.id = trunk.id;

#      trunk.keep = true
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

      console.log 'trunk', trunk.id , trunk.category.name + ' - weight = ' + trunk.weight + ' - rank = ' + trunk.rank + ' - angle = ' + trunk.angle + ' - width = ' + trunk.width + ' - from ('  + trunk.spX + ',' + trunk.spY  + ') to (' + trunk.epX + ',' + trunk.epY+')'

      start_points.push(ep);
      return t.branches();

    branches: () ->
      new_start_points = [];

      for sp in start_points
        parent_branch = m_branches[sp.id]

        if !parent_branch
          continue

        line_width = parent_branch.width * reduction;

        branches = parent_branch.branches
        t.sort_branches(branches)

        i = 1
        for b in branches
          branch = m_branches[b.id]
          only_leafs = (branch.branches.length == 0) and (branch.leafs.length < 4)

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
          branch.reduction = reduction

#          if branch.keep
#            console.log 'branch', branch.id , branch.category.name + ' - keep = ' + branch.keep + ' - weight = ' + branch.weight + ' - rank = ' + branch.rank + ' - angle = ' + branch.angle + ' - width = ' + branch.width + ' - from ('  + branch.spX + ',' + branch.spY  + ') to (' + branch.epX + ',' + branch.epY+')'

          if (branch.keep)
            ctx.beginPath();
            ctx.fillStyle = 'brown';
            ctx.strokeStyle = "brown";
            ctx.lineWidth = branch_length;
            ctx.lineWidth = branch_width;
            ctx.moveTo(sp.x, H - sp.y);
            ctx.lineTo(ep.x, H - ep.y);
            ctx.stroke();

            t.leafs(branch)

          new_start_points.push(ep);

      start_points = new_start_points;

      if (new_start_points.length)
        setTimeout(t.branches, 50);
      else
        t.name_branches()
      return

    leafs: (branch) ->
      j = 0
      leafs = branch.leafs
      no_branches = (branch.branches.length == 0) and (branch.leafs.length < 4)

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

#        if leaf.keep
#          console.log 'leaf', leaf.id ,  leaf.name + ' - keep = ' + leaf.keep + ' - angle = ' + leaf_angle + ' - from ('  + leaf.sp.x + ',' + (H - leaf.sp.y)  + ') to (' + leaf.ep.x + ',' + (H - leaf.ep.y) + ')'

#        if (!t.filter || leaf.keep)
#          leaf.keep = true
        if (leaf.keep)
          m_leafs[leaf.id] = leaf
          img = new Image();

          if leaf.link.link_meta_data && leaf.link.link_meta_data.domain_id
            domain_id = leaf.link.link_meta_data.domain_id
            img.src =   "favicons/#{domain_id}-favicon.ico"
            img.src = 'http://g.etfv.co/' + leaf.link.url
          else
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

    name_branches: () ->
      return false
      for k,branch of m_branches
        if branch.keep
          if branch.angle > 90
            x = branch.epX
            y = branch.epY
            angle = (180 - branch.angle)
          else
            x = branch.spX
            y = branch.spY
            angle = (360 - branch.angle)

          ctx.save();
          ctx.translate(x,y)
          ctx.rotate(angle * Math.PI/180);
          ctx.font = (branch.width.ceil + 0)+ "px Georgia";
          ctx.fillStyle = 'blue';
          ctx.fillText(branch.category.name, branch_name_padding, 0, branch.length - branch_name_padding);
          ctx.restore()

    set_branches_rank: (trunk) ->
      for b in trunk.branches
        branch = m_branches[b.id]
        branch.rank = trunk.rank + 1
        t.set_branches_rank(branch)

    set_branches_weight: (trunk) ->
      trunk.weight = 1 + trunk.leafs.length;
      for b in trunk.branches
        branch = m_branches[b.id]
        trunk.weight += t.set_branches_weight(branch)
      return trunk.weight

    sort_branches: (branches) ->
      branches.sort (a,b) ->
        aBranch = m_branches[a.id]
        bBranch = m_branches[b.id]
#        return (aBranch.branches.length + aBranch.leafs.length) - (bBranch.branches.length + bBranch.leafs.length)
        return aBranch.weight - bBranch.weight

      len = branches.length
      i = 0
      while (i < len - i && branches[len - i - 2])
        tmp = branches[i]
        branches[i] = branches[len - i - 2]
        branches[len - i - 2] = tmp
        i+=2

#      for i in [0...branches.length / 2] by 2
#        j = branches.length - 1 - i
#        tmp = branches[i]
#        branches[i] = branches[j]
#        branches[j] = tmp

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
      console.log e.currentTarget.id
      e.stopPropagation()
      if $("#tree-canvas").hasClass("zoom-in")
        $("#tree-canvas").removeClass("zoom-in")
        $scope.sketch_tree()

    onTipCanvasClick: (e) ->
      pt = t.getMouse(e, canvas);
      name = ''
      id = 0;
      type = ''
      showMenu = false

      e.stopPropagation()

      l = t.getLeafByPoint(pt.x, pt.y)
      if l
        name = l.name
        id = l.id
        type = 'leaf'
        $('.branch-action').hide()
        $('.leaf-action').show()
        $('#tree-canvas-stats-goto').attr("href", l.link.url);
        showMenu = true
      else
        b = t.getBranchByPoint(pt.x, pt.y)
        if b
          $('.leaf-action').hide()
          $('.branch-action').show()
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