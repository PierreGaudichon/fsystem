// Generated by CoffeeScript 1.8.0
(function() {
  var ItemView, parent;

  parent = function(pth) {
    pth = _.compact(pth.split("/"));
    if (pth.length === 0) {
      return "/";
    } else {
      pth.length -= 1;
      return "/" + pth.join("/");
    }
  };

  ItemView = (function() {
    ItemView.prototype.el = "jQuery";

    ItemView.prototype.path = "/";

    ItemView.prototype.item = {};

    function ItemView(el) {
      this.el = el;
      this.list = this.el.find(".list");
      this.content = this.el.find(".content");
    }

    ItemView.prototype.open = function(path) {
      this.path = path;
      $.getJSON("open", {
        path: this.path
      }).done((function(_this) {
        return function(data) {
          _this.item = data;
          return _this.template();
        };
      })(this)).fail(function() {
        return console.log("fail loading : " + this.path + ".");
      });
      return null;
    };

    ItemView.prototype.template = function() {
      switch (this.item.item) {
        case "folder":
          return this.templateFolder();
        case "file":
          return this.templateFile();
      }
    };

    ItemView.prototype.templateFolder = function() {
      var item, _fn, _i, _len, _ref;
      this.templateEmpty();
      _ref = this.item.inside;
      _fn = (function(_this) {
        return function(item) {
          var el;
          el = $("<li />").text(item.name).click(function() {
            return _this.open(item.path);
          });
          return _this.list.append(el);
        };
      })(this);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        _fn(item);
      }
      return null;
    };

    ItemView.prototype.templateFile = function() {
      var p;
      this.templateEmpty();
      p = parent(this.item.path);
      this.content.find(".parent").text(p).click((function(_this) {
        return function() {
          return _this.open(p);
        };
      })(this));
      this.content.find("h2").text(this.item.name);
      return this.content.find("pre").text(this.item.content || "Not text file.");
    };

    ItemView.prototype.templateEmpty = function() {
      this.list.empty();
      return this.content.children().empty();
    };

    ItemView.prototype.initialize = function() {
      return $.getJSON("root").done((function(_this) {
        return function(data) {
          return _this.open(data.root);
        };
      })(this)).fail(function() {
        return console.log("root : failed");
      });
    };

    return ItemView;

  })();

  $(function() {
    var view;
    view = new ItemView($(".view"));
    return view.initialize();
  });

}).call(this);
