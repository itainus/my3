// Copyright (c) 2012 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// The onClicked callback function.
function onClickHandler(info, tab) {
    if (info.menuItemId == "radio1" || info.menuItemId == "radio2")
    {
        //alert("radio item " + info.menuItemId + " was clicked (previous checked state was "  + info.wasChecked + ")");
    }
    else if (info.menuItemId == "checkbox1" || info.menuItemId == "checkbox2")
    {
        //alert(JSON.stringify(info));
        //alert("checkbox item " + info.menuItemId + " was clicked, state is now: " + info.checked + " (previous state was " + info.wasChecked + ")");

    }
    else
    {
        //alert("item " + info.menuItemId + " was clicked");
        //alert("info: " + JSON.stringify(info));
        //alert("tab: " + JSON.stringify(tab));
    }

    alert('about to loadMy3()');

    var details = {
        title: info.selectionText,
        url: info.linkUrl,
        editable: info.editable,
        id: info.menuItemId,
        pageUrl: info.pageUrl,
        text: info.selectionText
    };


    chrome.windows.create({ url: 'popup.html', type: 'popup', width: 300, height: 200 }, function() {
        chrome.runtime.sendMessage({ details: details }, function(response) {
            alert(response)
        });
    });
};

chrome.contextMenus.onClicked.addListener(onClickHandler);

// Set up context menu tree at install time.
chrome.runtime.onInstalled.addListener(function() {
    // Create one test item for each context type.
    var contexts = ["page","selection","link","editable","image","video","audio"];

    for (var i = 0; i < contexts.length; i++)
    {
        var context = contexts[i];
        var title = "Test '" + context + "' menu item";
        var id = chrome.contextMenus.create({"title": title, "contexts":[context], "id": "context" + context});

        //alert("'" + context + "' item:" + id);
    }

    // Create a parent item and two children.
    chrome.contextMenus.create({"title": "Test parent item", "id": "parent"});
    chrome.contextMenus.create({"title": "Child 1", "parentId": "parent", "id": "child1"});
    chrome.contextMenus.create({"title": "Child 2", "parentId": "parent", "id": "child2"});
    //alert("parent child1 child2");

    // Create some radio items.
    chrome.contextMenus.create({"title": "Radio 1", "type": "radio", "id": "radio1"});
    chrome.contextMenus.create({"title": "Radio 2", "type": "radio", "id": "radio2"});
    //alert("radio1 radio2");

    // Create some checkbox items.
    chrome.contextMenus.create({"title": "Checkbox1", "type": "checkbox", "id": "checkbox1"});
    chrome.contextMenus.create({"title": "Checkbox2", "type": "checkbox", "id": "checkbox2"});
    //alert("checkbox1 checkbox2");

    // Intentionally create an invalid item, to show off error checking in the
    // create callback.
    //alert("About to try creating an invalid item - an error about " + "duplicate item child1 should show up");

    chrome.contextMenus.create({"title": "Oops", "id": "child1"}, function() {
        if (chrome.extension.lastError) {
            //alert("Got expected error: " + chrome.extension.lastError.message);
        }
    });
});
