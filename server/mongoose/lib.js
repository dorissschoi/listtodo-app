// Generated by CoffeeScript 1.7.1
(function() {
  var Period, ensurePermission, field, model, order, order_by;

  model = require('../../model.coffee');

  field = function(name) {
    if (name.charAt(0) === '-') {
      return name.substring(1);
    }
    return name;
  };

  order = function(name) {
    if (name.charAt(0) === '-') {
      return -1;
    }
    return 1;
  };

  order_by = function(name) {
    var ret;
    ret = {};
    ret[field(name)] = order(name);
    return ret;
  };

  ensurePermission = function(p) {
    return function(req, res, next) {
      var user;
      user = req.user;
      if (p === 'todo:create' || p === 'todo:list') {
        return next();
      }
      return model.Todo.findOne({
        id: req.param.id
      }, function(err, todo) {
        if (err || todo === null) {
          return res.json(501, {
            error: err
          });
        }
        if (todo.createdBy.id === user._id.id) {
          return next();
        } else {
          return res.json(401, {
            error: 'Unauthorzied access'
          });
        }
      });
    };
  };

  Period = (function() {
    function Period(start, end) {
      this.start = start;
      this.end = end;
    }

    Period.prototype.contain = function(strdate) {
      var cond1, cond2;
      cond1 = {};
      cond2 = {};
      cond1[strdate] = {
        $gte: this.start
      };
      cond2[strdate] = {
        $lte: this.end
      };
      return {
        $or: [cond1, cond2]
      };
    };

    Period.prototype.ncontain = function(strdate) {
      var cond1, cond2;
      cond1 = {};
      cond2 = {};
      cond1[strdate] = {
        $lt: this.start
      };
      cond2[strdate] = {
        $gt: this.end
      };
      return {
        $or: [cond1, cond2]
      };
    };

    Period.prototype.intersect = function(strstart, strend) {
      var a, b, c, d;
      a = this.contain(strstart);
      b = this.contain(strend);
      c = this.ncontain(strstart);
      d = this.ncontain(strend);
      return {
        $or: [
          {
            $or: [a, b]
          }, {
            $and: [c, d]
          }
        ]
      };
    };

    Period.prototype.isContain = function(date) {
      return this.start.getTime() <= date.getTime() && date.getTime() <= this.end.getTime();
    };

    Period.prototype.isIntersect = function(period) {
      return !((this.start.getTime() > period.start.getTime() && this.start.getTime() > period.end.getTime()) || (this.end.getTime() < period.start.getTime() && this.end.getTime() < period.end.getTime()));
    };

    return Period;

  })();

  module.exports = {
    field: field,
    order: order,
    order_by: order_by,
    ensurePermission: ensurePermission,
    Period: Period
  };

}).call(this);