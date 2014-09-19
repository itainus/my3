
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

	treeID: 0,
    xsrfToken: '',

	addLinkCallback: function(e)
	{
		console.log ('my3 - addLinkCallback', e);

		var tree = JSON.parse(e.target.response);

		console.log (tree);

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

	addLink: function()
	{
		console.log ('my3 - addLink');

		chrome.tabs.getSelected(null,function(tab) {
			console.log(tab);
			var tabLink = tab.url;
			var tabTitle = tab.title;

			$.ajax({
		  		url: "http://localhost:3000/home/trees",
		  		context: document.body
			}).done(function(e) {

		  		console.log(this);
		  		console.log(e);
			
				var trees = e;
				var tree = trees[0];//JSON.parse(e);

                My3.treeID = tree.id;
                var treeID = tree.id;
			  	var treeName = tree.name;
			  
				$('#tree-container').text('[' + treeID + ']' + treeName);		  	

				$('#add-link-name').val(tabTitle);
				$('#add-link-url').val(tabLink);

                $.ajax({
                    url: "http://localhost:3000/tree/" + My3.treeID + "/suggest_branch",
                    context: document.body,
                    type: "GET",
                    data: {link_url: tabLink},
                    dataType: 'json'
                }).done(function(category) {

                    console.log(category);

                    var addLinkCategorySelect = $('#add-link-category');

                    if (category.id) {
                        addLinkCategorySelect.append('<option value="' + category.id + '">' + category.name + '</option>');
                        addLinkCategorySelect.append('<option disabled="disabled" value="?">' + '__________________________' + '</option>');
                    }

                    $.each(tree.branches, function() {
                        var b = this;
                        //console.log(b)
                        addLinkCategorySelect.append('<option value="' + b.category.id + '">' + b.category.name + '</option>');//.val(leaf.id).text(this.Name));
                    });
                });
			});
		});  
	}
};


document.addEventListener('DOMContentLoaded', function () {

    var details = {
        'url' : 'http://localhost:3000/',
        'name' : 'XSRF-TOKEN'
    };

    chrome.cookies.get(details, function(cookie){

        console.log(cookie);

        My3.xsrfToken = decodeURIComponent(cookie.value);
    });

    My3.addLink();

	$( "#add-link-btn" ).click(function() {

		var data = {
			link_name: $('#add-link-name').val(),
			link_url: $('#add-link-url').val(),
			link_category_id: $('#add-link-category').val()
		};

        //var xsrfToken = "p9OKwdItdwdt+sR7M6SIllZrpH8/gW8ANcMULSBM4fo=";

		$.ajax({
			type: "POST",
			url: "http://localhost:3000/tree/" + My3.treeID + "/link_create",
			data: data,
			dataType: 'json',
			success: function(response)
			{
				console.log(response);
				//alert( "added!" );
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
});