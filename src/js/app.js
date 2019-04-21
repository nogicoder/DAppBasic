App = {
    web3Provider: null,
    contracts: {},
    init: async function() {
        // Load cards.
        $.getJSON("./cards.json", function(data) {
            var cardsRow = $("#cardsRow");
            var cardTemplate = $("#cardTemplate");
            for (i = 0; i < data.length; i++) {
                cardTemplate.find(".panel-title").text(data[i].name);
                cardTemplate.find("img").attr("src", data[i].picture);
                cardTemplate.find(".attack").text(data[i].attack);
                cardTemplate.find(".defense").text(data[i].defense);
                cardTemplate.find(".btn-adopt").attr("data-id", data[i].id);
                cardsRow.append(cardTemplate.html());
            }
        });

        return await App.initWeb3();
    },

    initWeb3: async function() {
        // Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access");
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache
        else {
            App.web3Provider = new Web3.providers.HttpProvider(
                "http://localhost:7545"
            );
        }
        web3 = new Web3(App.web3Provider);

        return App.test();
    },

    test: function() {
        console.log(web3.version.network);
        // web3.eth.net.getNetworkType().then(console.log);
    }
};
$(document).ready(function() {
    App.init();
});