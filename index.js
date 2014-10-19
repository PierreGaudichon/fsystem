// Generated by CoffeeScript 1.8.0
(function() {
  var app, express, file, folder, fs, parent, path, readDir, readFile, removeHidden, _;

  express = require("express");

  path = require("path");

  fs = require("fs");

  _ = require("lodash");

  app = express();

  folder = {
    path: "/home/pierre",
    name: "pierre",
    size: 15,
    inside: []
  };

  file = {
    path: "/home/pierre/test",
    name: "test",
    type: "ASCII text",
    content: {}
  };

  removeHidden = function(files) {
    return _.filter(files, function(f) {
      return f[0] !== ".";
    });
  };

  parent = function(pth) {
    pth = _.compact(pth.split("/"));
    if (pth.length === 0) {
      return "/";
    } else {
      pth.length -= 1;
      return "/" + pth.join("/");
    }
  };

  readDir = function(pth, stats, callback) {
    var r;
    r = {
      item: "folder",
      path: pth,
      name: path.basename(pth),
      inside: []
    };
    if (pth !== "/") {
      r.inside.push({
        path: parent(pth),
        name: ".."
      });
    }
    return fs.readdir(pth, function(err, files) {
      var f, _i, _len, _ref;
      r.size = files.length;
      _ref = removeHidden(files);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        f = _ref[_i];
        r.inside.push({
          path: path.join(pth, f),
          name: f
        });
      }
      return callback(err, r);
    });
  };

  readFile = function(pth, stats, callback) {
    var r;
    r = {
      item: "file",
      path: pth,
      name: path.basename(pth),
      type: "unknown",
      size: stats.size
    };
    if (r.size < Math.pow(10, 5) * 8) {
      return fs.readFile(r.path, {
        encoding: "utf-8"
      }, function(err, data) {
        r.content = data;
        return callback(err, r);
      });
    } else {
      return callback(null, r);
    }
  };

  app.use(express["static"](path.join(__dirname, "public")));

  app.use(express["static"](path.join(__dirname, "bower_components")));

  app.use(express["static"](path.join(__dirname, "node_modules")));

  app.get("/root", function(req, res) {
    var home;
    home = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
    return res.send(JSON.stringify({
      root: home
    }));
  });

  app.get("/open", function(req, res) {
    var pth;
    pth = req.query.path;
    console.log("/open : " + pth);
    return fs.lstat(pth, function(err, stats) {
      if (stats.isDirectory()) {
        return readDir(pth, stats, function(err, data) {
          return res.send(JSON.stringify(data));
        });
      } else if (stats.isFile()) {
        return readFile(pth, stats, function(err, data) {
          return res.send(JSON.stringify(data));
        });
      } else {
        return res.send("");
      }
    });
  });

  app.listen(1337);

}).call(this);
