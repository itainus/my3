
My3Domain = 'my-3.herokuapp.com';
My3Domain = 'localhost:3000';

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if (c.indexOf(name) != -1) return c.substring(name.length,c.length);
    }
    return "";
}

var My3 = {
    wsUrl:'ws://' + My3Domain + '/websocket',
    url: 'http://' + My3Domain,
    trees: null,
    treeIndex: 0,
	treeID: 0,
    xsrfToken: '',
    suggestCategory: {},

	addLinkCallback: function(e)
	{
		//console.log ('my3 - addLinkCallback', e);

		var tree = JSON.parse(e.target.response);

		//console.log (tree);

		var div = document.createElement('div');
		div.innerHTML = tree.name;
      	document.body.appendChild(div);


      	chrome.tabs.getSelected(null,function(tab) {
	    	var tablink = tab.url;
	    	console.log(tab);

	    	var div = document.createElement('div');
			div.innerHTML = tablink;
	      	document.body.appendChild(div);
		});
	},

    populateCategories: function(selectedCategoryID)
    {
        var suggestCategory = My3.suggestCategory;
        var treeIndex = My3.treeIndex;
        var tree = My3.trees[treeIndex];

        var addLinkCategorySelect = $('#add-link-category');
        var addCategoryParentSelect = $('#add-category-parent');

        addLinkCategorySelect.empty();
        addCategoryParentSelect.empty();

        if (suggestCategory.id) {
            addLinkCategorySelect.append('<option value="' + suggestCategory.id + '">' + suggestCategory.name + '</option>');
            addLinkCategorySelect.append('<option disabled="disabled" value="?">' + '__________________________' + '</option>');
        }

        var selected;
        $.each(tree.branches, function() {
            var b = this;
            //console.log(b)
            selected = '';

            if (b.category.id == selectedCategoryID)
            {
                selected = 'selected="selected"';
            }

            addLinkCategorySelect.append('<option value="' + b.category.id + '" ' + selected + '>' + b.category.name + '</option>');//.val(leaf.id).text(this.Name));
            addCategoryParentSelect.append('<option value="' + b.category.id + '" ' + selected + '>' + b.category.name + '</option>');
        });
    },

    initWS: function()
    {

        testWebSocket();

        function testWebSocket() {
            My3.ws = new WebSocket(My3.wsUrl);
            My3.ws.onopen = function(evt) { onOpen(evt) };
            My3.ws.onclose = function(evt) { onClose(evt) };
            My3.ws.onmessage = function(evt) { onMessage(evt) };
            My3.ws.onerror = function(evt) { onError(evt) };
        }

        function onOpen(evt) {
            console.log('CONNECTED',evt)
        }
        function onClose(evt) {
            console.log('DISCONNECTED',evt)
        }
        function onMessage(evt) {
            console.log('onMessage',evt);
//            My3.ws.close();
        }
        function onError(evt) {
            console.log('onError',evt)
        }
        function doSend(message) {
            console.log('doSend',message)
            My3.ws.send(message);
        }
    },

	init: function()
	{
		console.log ('my3 - init');

       // this.initWS();

        chrome.cookies.get({'url': My3.url, 'name': 'XSRF-TOKEN'}, function(cookie){
             My3.xsrfToken = decodeURIComponent(cookie.value);
        });

		chrome.tabs.getSelected(null,function(tab) {
			console.log('tab', tab);
			var tabLink = tab.url;
			var tabTitle = tab.title;
            var favIconUrl = tab.favIconUrl;

			$.ajax({
		  		url: My3.url + "/home/trees",
		  		context: document.body
			}).done(function(t) {
			
				My3.trees = t;
                var treeIndex = My3.treeIndex;
				var tree = My3.trees[treeIndex];//JSON.parse(e);

                My3.treeID = tree.id;
			  	var treeName = tree.name;
			  
				$('#tree-container').text(treeName);
				$('#add-link-name').val(tabTitle);
				$('#add-link-url').val(tabLink);
                $('#add-link-img').val(favIconUrl);

                $.ajax({
                    url:  My3.url + "/tree/" + My3.treeID + "/suggest_branch",
                    context: document.body,
                    type: "GET",
                    data: {link_url: tabLink},
                    dataType: 'json'
                }).done(function(category) {

                    console.log('suggest_category', category);
                    My3.suggestCategory = category;

                    My3.populateCategories(category.id);

                });
			});
		});  
	}
};


document.addEventListener('DOMContentLoaded', function () {

    My3.init();

	$("#save-link-btn" ).click(function() {

		var data = {
			link_name: $('#add-link-name').val(),
			link_url: $('#add-link-url').val(),
			link_category_id: $('#add-link-category').val(),
            link_img: $('#add-link-img').val()
		};

		$.ajax({
			type: "POST",
			url:  My3.url + "/tree/" + My3.treeID + "/link_create",
			data: data,
			dataType: 'json',
			success: function(response)
			{
                window.close();
			},
			fail: function(e)
			{
				console.error(e);
			}
			,headers: { 
		        "X-XSRF-TOKEN" : My3.xsrfToken
	        }
		});
	});

    $('#add-category-form-back').click(function(e) {
        e.stopPropagation();
        $('#add-category-form').hide();
        $('#add-link-form').show();
    });

    $('#add-category-btn').click(function() {
        $('#add-link-form').hide();
        $('#add-category-form').show();
    });

    $('#save-category-btn').click(function() {

        var data = {
            category_name: $('#add-category-name').val(),
            category_parent_id: $('#add-category-parent').val()
        };

        $.ajax({
            type: "POST",
            url: My3.url + "/tree/" + My3.treeID + "/category_create",
            data: data,
            dataType: 'json',
            success: function(response)
            {
                if (response.success) {
                    var tree = My3.trees[My3.treeIndex];

                    tree.branches.push(response.branch);

                    My3.populateCategories(response.branch.category.id);

                    $('#add-category-form').hide();
                    $('#add-link-form').show();
                }
                else
                {
                    console.error(response)
                }
            },
            fail: function(e)
            {
                console.error(e);
            }
            ,headers: {
                "X-XSRF-TOKEN" : My3.xsrfToken
            }
        });
    });

//    $('#test-btn').click(function(e) {
//        e.stopPropagation();
//        console.log('test-btn clicked');
//        My3.ws.send('["tree.update",{"data":{"testing_ws":true,"user_id":8888}}]');
//        return false;
//    });

});