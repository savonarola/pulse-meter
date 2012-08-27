
String.prototype.capitalize = function() {
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.strip = function() {
  if (String.prototype.trim != null) {
    return this.trim();
  } else {
    return this.replace(/^\s+|\s+$/g, "");
  }
};

Number.prototype.humanize = function() {
  var d, h, interval, m, res, s;
  interval = this;
  res = "";
  s = interval % 60;
  if (s > 0) {
    res = "" + s + " s";
  }
  interval = (interval - s) / 60;
  if (!(interval > 0)) {
    return res;
  }
  m = interval % 60;
  if (m > 0) {
    res = ("" + m + " m " + res).strip();
  }
  interval = (interval - m) / 60;
  if (!(interval > 0)) {
    return res;
  }
  h = interval % 24;
  if (h > 0) {
    res = ("" + h + " h " + res).strip();
  }
  d = (interval - h) / 24;
  if (d > 0) {
    return ("" + d + " d " + res).strip();
  } else {
    return res;
  }
};
var PageInfo;

PageInfo = Backbone.Model.extend({});
var Widget;

Widget = Backbone.Model.extend({
  initialize: function() {
    this.needRefresh = true;
    this.setNextFetch();
    return this.timespanInc = 0;
  },
  increaseTimespan: function(inc) {
    this.timespanInc = this.timespanInc + inc;
    return this.forceUpdate();
  },
  resetTimespan: function() {
    this.timespanInc = 0;
    return this.forceUpdate();
  },
  timespan: function() {
    return this.get('timespan') + this.timespanInc;
  },
  url: function() {
    var timespan;
    timespan = this.timespan();
    if (_.isNaN(timespan)) {
      return "" + (this.collection.url()) + "/" + (this.get('id'));
    } else {
      return "" + (this.collection.url()) + "/" + (this.get('id')) + "?timespan=" + timespan;
    }
  },
  time: function() {
    return (new Date()).getTime();
  },
  setNextFetch: function() {
    return this.nextFetch = this.time() + this.get('redrawInterval') * 1000;
  },
  setRefresh: function(needRefresh) {
    return this.needRefresh = needRefresh;
  },
  needFetch: function() {
    var interval;
    interval = this.get('redrawInterval');
    return this.time() > this.nextFetch && this.needRefresh && (interval != null) && interval > 0;
  },
  refetch: function() {
    if (this.needFetch()) {
      this.forceUpdate();
      return this.setNextFetch();
    }
  },
  forceUpdate: function() {
    return this.fetch({
      success: function(model, response) {
        return model.trigger('redraw');
      }
    });
  }
});
var DynamicWidget;

DynamicWidget = Backbone.Model.extend({
  increaseTimespan: function(inc) {
    return this.set('timespan', this.timespan() + inc);
  },
  resetTimespan: function() {
    return this.set('timespan', null);
  },
  timespan: function() {
    return this.get('timespan');
  },
  sensorArgs: function() {
    return _.map(this.get('sensorIds'), function(name) {
      return "sensor[]=" + name;
    }).join('&');
  },
  url: function() {
    var timespan, url;
    url = "" + ROOT + "dynamic_widget?" + (this.sensorArgs()) + "&type=" + (this.get('type'));
    timespan = this.timespan();
    if ((timespan != null) && !_.isNaN(timespan)) {
      url = "" + url + "&timespan=" + timespan;
    }
    return url;
  },
  forceUpdate: function() {
    return this.fetch({
      success: function(model, response) {
        return model.trigger('redraw');
      }
    });
  }
});
var SensorInfo;

SensorInfo = Backbone.Model.extend({});
var PageInfoList;

PageInfoList = Backbone.Collection.extend({
  model: PageInfo,
  selected: function() {
    return this.find(function(m) {
      return m.get('selected');
    });
  },
  selectFirst: function() {
    if (this.length > 0) {
      return this.at(0).set('selected', true);
    }
  },
  selectNone: function() {
    return this.each(function(m) {
      return m.set('selected', false);
    });
  },
  selectPage: function(id) {
    return this.each(function(m) {
      return m.set('selected', m.id === id);
    });
  }
});
var SensorInfoList;

SensorInfoList = Backbone.Collection.extend({
  model: SensorInfo,
  url: function() {
    return ROOT + 'sensors';
  }
});
var WidgetList;

WidgetList = Backbone.Collection.extend({
  model: Widget,
  setContext: function(pageInfos) {
    this.pageInfos = pageInfos;
  },
  url: function() {
    return ROOT + 'pages/' + this.pageInfos.selected().id + '/widgets';
  }
});
var PageTitleView;

PageTitleView = Backbone.View.extend({
  tagName: 'li',
  template: _.template('<a href="#/pages/<%= id  %>"><%= title %></a>'),
  initialize: function() {
    this.model.bind('change', this.render, this);
    return this.model.bind('destroy', this.remove, this);
  },
  render: function() {
    this.$el.html(this.template(this.model.toJSON()));
    if (this.model.get('selected')) {
      return this.$el.addClass('active');
    } else {
      return this.$el.removeClass('active');
    }
  }
});
var PageTitlesView;

PageTitlesView = Backbone.View.extend({
  initialize: function(pageInfos) {
    this.pageInfos = pageInfos;
    return this.pageInfos.bind('reset', this.render, this);
  },
  addOne: function(pageInfo) {
    var view;
    view = new PageTitleView({
      model: pageInfo
    });
    view.render();
    return $('#page-titles').append(view.el);
  },
  render: function() {
    $('#page-titles').empty();
    return this.pageInfos.each(this.addOne);
  }
});
var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

document.startApp = function() {
  var AppRouter, AreaPresenter, DynamicChartView, DynamicWidgetView, GaugePresenter, LinePresenter, PiePresenter, SensorInfoListView, SeriesPresenter, TablePresenter, TimelinePresenter, WidgetChartView, WidgetListView, WidgetPresenter, WidgetView, appRouter, globalOptions, pageInfos, pageTitlesApp, widgetList, widgetListApp;
  globalOptions = gon.options;
  pageInfos = new PageInfoList;
  pageTitlesApp = new PageTitlesView(pageInfos);
  pageInfos.reset(gon.pageInfos);
  WidgetPresenter = (function() {

    function WidgetPresenter(model, el) {
      var chartClass;
      this.model = model;
      chartClass = this.chartClass();
      this.chart = new chartClass(el);
      this.draw();
    }

    WidgetPresenter.prototype.get = function(arg) {
      return this.model.get(arg);
    };

    WidgetPresenter.prototype.dateOffset = function() {
      if (globalOptions.useUtc) {
        return (new Date).getTimezoneOffset() * 60000;
      } else {
        return 0;
      }
    };

    WidgetPresenter.prototype.options = function() {
      return {
        title: this.get('title'),
        height: 300
      };
    };

    WidgetPresenter.prototype.mergedOptions = function() {
      var pageOptions;
      pageOptions = pageInfos.selected() ? pageInfos.selected().get('gchartOptions') : {};
      return $.extend(true, this.options(), globalOptions.gchartOptions, pageOptions, this.get('gchartOptions'));
    };

    WidgetPresenter.prototype.data = function() {
      return new google.visualization.DataTable;
    };

    WidgetPresenter.prototype.chartClass = function() {
      return google.visualization[this.visualization];
    };

    WidgetPresenter.prototype.cutoff = function() {};

    WidgetPresenter.prototype.cutoffValue = function(v, min, max) {
      if (v != null) {
        if ((min != null) && v < min) {
          return min;
        } else if ((max != null) && v > max) {
          return max;
        } else {
          return v;
        }
      } else {
        return 0;
      }
    };

    WidgetPresenter.prototype.draw = function(min, max) {
      this.cutoff(min, max);
      return this.chart.draw(this.data(), this.mergedOptions());
    };

    return WidgetPresenter;

  })();
  WidgetPresenter.create = function(model, el) {
    var presenterClass, type;
    type = model.get('type');
    if ((type != null) && type.match(/^\w+$/)) {
      presenterClass = eval("" + (type.capitalize()) + "Presenter");
      return new presenterClass(model, el);
    } else {
      return null;
    }
  };
  PiePresenter = (function(_super) {

    __extends(PiePresenter, _super);

    function PiePresenter() {
      return PiePresenter.__super__.constructor.apply(this, arguments);
    }

    PiePresenter.prototype.visualization = 'PieChart';

    PiePresenter.prototype.cutoff = function() {};

    PiePresenter.prototype.data = function() {
      var data;
      data = PiePresenter.__super__.data.call(this);
      data.addColumn('string', 'Title');
      data.addColumn('number', this.get('valuesTitle'));
      data.addRows(this.get('series').data);
      return data;
    };

    PiePresenter.prototype.options = function() {
      return $.extend(true, PiePresenter.__super__.options.call(this), {
        slices: this.get('series').options,
        legend: {
          position: 'bottom'
        }
      });
    };

    return PiePresenter;

  })(WidgetPresenter);
  TimelinePresenter = (function(_super) {

    __extends(TimelinePresenter, _super);

    function TimelinePresenter() {
      return TimelinePresenter.__super__.constructor.apply(this, arguments);
    }

    TimelinePresenter.prototype.data = function() {
      var data, dateOffset, series;
      data = TimelinePresenter.__super__.data.call(this);
      data.addColumn('datetime', 'Time');
      dateOffset = this.dateOffset() + this.get('interval') * 1000;
      series = this.get('series');
      _.each(series.titles, function(t) {
        return data.addColumn('number', t);
      });
      _.each(series.rows, function(row) {
        row[0] = new Date(row[0] + dateOffset);
        return data.addRow(row);
      });
      return data;
    };

    return TimelinePresenter;

  })(WidgetPresenter);
  SeriesPresenter = (function(_super) {

    __extends(SeriesPresenter, _super);

    function SeriesPresenter() {
      return SeriesPresenter.__super__.constructor.apply(this, arguments);
    }

    SeriesPresenter.prototype.options = function() {
      var format, secondPart;
      secondPart = this.get('interval') % 60 === 0 ? '' : ':ss';
      format = this.model.timespan() > 24 * 60 * 60 ? "yyyy.MM.dd HH:mm" + secondPart : "HH:mm" + secondPart;
      return $.extend(true, SeriesPresenter.__super__.options.call(this), {
        lineWidth: 1,
        chartArea: {
          width: '100%'
        },
        legend: {
          position: 'bottom'
        },
        vAxis: {
          title: this.valuesTitle(),
          textPosition: 'in'
        },
        hAxis: {
          format: format
        },
        series: this.get('series').options,
        axisTitlesPosition: 'in'
      });
    };

    SeriesPresenter.prototype.valuesTitle = function() {
      if (this.get('valuesTitle')) {
        return "" + (this.get('valuesTitle')) + " / " + (this.humanizedInterval());
      } else {
        return this.humanizedInterval();
      }
    };

    SeriesPresenter.prototype.humanizedInterval = function() {
      return this.get('interval').humanize();
    };

    SeriesPresenter.prototype.cutoff = function(min, max) {
      return _.each(this.get('series').rows, function(row) {
        var i, value, _i, _ref, _results;
        _results = [];
        for (i = _i = 1, _ref = row.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          value = row[i];
          if (value == null) {
            value = 0;
          }
          _results.push(row[i] = this.cutoffValue(value, min, max));
        }
        return _results;
      }, this);
    };

    return SeriesPresenter;

  })(TimelinePresenter);
  LinePresenter = (function(_super) {

    __extends(LinePresenter, _super);

    function LinePresenter() {
      return LinePresenter.__super__.constructor.apply(this, arguments);
    }

    LinePresenter.prototype.visualization = 'LineChart';

    return LinePresenter;

  })(SeriesPresenter);
  AreaPresenter = (function(_super) {

    __extends(AreaPresenter, _super);

    function AreaPresenter() {
      return AreaPresenter.__super__.constructor.apply(this, arguments);
    }

    AreaPresenter.prototype.visualization = 'AreaChart';

    return AreaPresenter;

  })(SeriesPresenter);
  TablePresenter = (function(_super) {

    __extends(TablePresenter, _super);

    function TablePresenter() {
      return TablePresenter.__super__.constructor.apply(this, arguments);
    }

    TablePresenter.prototype.visualization = 'Table';

    TablePresenter.prototype.cutoff = function() {};

    TablePresenter.prototype.options = function() {
      return $.extend(true, TablePresenter.__super__.options.call(this), {
        sortColumn: 0,
        sortAscending: false
      });
    };

    return TablePresenter;

  })(TimelinePresenter);
  GaugePresenter = (function(_super) {

    __extends(GaugePresenter, _super);

    function GaugePresenter() {
      return GaugePresenter.__super__.constructor.apply(this, arguments);
    }

    GaugePresenter.prototype.visualization = 'Gauge';

    GaugePresenter.prototype.cutoff = function() {};

    GaugePresenter.prototype.data = function() {
      var data;
      data = GaugePresenter.__super__.data.call(this);
      data.addColumn('string', 'Label');
      data.addColumn('number', this.get('valuesTitle'));
      data.addRows(this.get('series'));
      return data;
    };

    return GaugePresenter;

  })(WidgetPresenter);
  SensorInfoListView = Backbone.View.extend({
    tagName: 'div',
    template: function() {
      return _.template($("#sensor-list").html());
    },
    initialize: function(sensorInfo) {
      this.sensorInfo = sensorInfo;
      return this.sensorInfo.bind('reset', this.render, this);
    },
    render: function() {
      return this.$el.html(this.template()({
        sensors: this.sensorInfo.toJSON()
      }));
    },
    selectedSensors: function() {
      var checked, ids, selected;
      checked = _.filter(this.$el.find('.sensor-box'), function(el) {
        return $(el).is(':checked');
      });
      ids = {};
      _.each(checked, function(box) {
        return ids[box.id] = true;
      });
      return selected = this.sensorInfo.filter(function(sensor) {
        return ids[sensor.id];
      });
    }
  });
  DynamicChartView = Backbone.View.extend({
    initialize: function() {
      this.sensors = [];
      this.type = 'Area';
      this.widget = new DynamicWidget;
      this.widget.bind('destroy', this.remove, this);
      return this.widget.bind('redraw', this.redrawChart, this);
    },
    tagName: 'div',
    events: {
      "click #refresh-chart": 'update',
      "click #extend-timespan": 'extendTimespan',
      "click #reset-timespan": 'resetTimespan'
    },
    template: function() {
      return _.template($("#dynamic-widget-plotarea").html());
    },
    render: function() {
      return this.$el.html(this.template()());
    },
    extendTimespan: function() {
      var select, val;
      select = this.$el.find("#extend-timespan-val");
      val = select.first().val();
      this.widget.increaseTimespan(parseInt(val));
      return this.update();
    },
    resetTimespan: function() {
      this.widget.resetTimespan();
      return this.update();
    },
    sensorIds: function() {
      return _.map(this.sensors, function(s) {
        return s.id;
      });
    },
    redrawChart: function() {
      if (this.presenter) {
        return this.presenter.draw();
      } else {
        return this.presenter = WidgetPresenter.create(this.widget, this.chartContainer());
      }
    },
    chartContainer: function() {
      return this.$el.find('#chart')[0];
    },
    update: function() {
      if (this.sensors.length > 0) {
        return this.widget.forceUpdate();
      }
    },
    draw: function(sensors, type) {
      this.sensors = sensors;
      this.type = type;
      this.widget.set('sensorIds', this.sensorIds());
      this.widget.set('type', this.type);
      this.presenter = null;
      $(this.chartContainer()).empty();
      return this.widget.forceUpdate();
    }
  });
  DynamicWidgetView = Backbone.View.extend({
    tagName: 'div',
    initialize: function() {
      this.sensorInfo = new SensorInfoList;
      this.sensorListView = new SensorInfoListView(this.sensorInfo);
      this.chartView = new DynamicChartView;
      this.$el.html(this.template()());
      this.$el.find('#sensor-list-area').append(this.sensorListView.el);
      this.chartView.render();
      return this.$el.find('#dynamic-plotarea').append(this.chartView.el);
    },
    events: {
      "click #sensor-controls #refresh": 'refresh',
      "click #sensor-controls #draw": 'drawChart'
    },
    template: function() {
      return _.template($("#dynamic-widget").html());
    },
    errorTemplate: function() {
      return _.template($("#dynamic-widget-error").html());
    },
    error: function(error) {
      return this.$el.find('#errors').append(this.errorTemplate()({
        error: error
      }));
    },
    refresh: function() {
      return this.sensorInfo.fetch();
    },
    intervalsEqual: function(sensors) {
      var badIntervals, interval;
      interval = sensors[0].get('interval');
      badIntervals = _.filter(sensors, function(s) {
        return s.get('interval') !== interval;
      });
      return badIntervals.length === 0;
    },
    drawChart: function() {
      var selectedSensors, type;
      selectedSensors = this.sensorListView.selectedSensors();
      if (!(selectedSensors.length > 0)) {
        return;
      }
      if (!this.intervalsEqual(selectedSensors)) {
        this.error('Selected sensors have different intervals');
        return;
      }
      type = this.$el.find('#chart-type').val();
      return this.chartView.draw(selectedSensors, type);
    },
    render: function(container) {
      container.empty();
      container.append(this.$el);
      this.sensorInfo.fetch();
      return this.chartView.update();
    }
  });
  WidgetChartView = Backbone.View.extend({
    tagName: 'div',
    initialize: function() {
      return this.model.bind('destroy', this.remove, this);
    },
    updateData: function(min, max) {
      return this.presenter.draw(min, max);
    },
    render: function() {
      return this.presenter = WidgetPresenter.create(this.model, this.el);
    }
  });
  WidgetView = Backbone.View.extend({
    tagName: 'div',
    template: function() {
      return _.template($(".widget-template[data-widget-type=\"" + (this.model.get('type')) + "\"]").html());
    },
    initialize: function() {
      this.model.bind('destroy', this.remove, this);
      return this.model.bind('redraw', this.updateChart, this);
    },
    events: {
      "click #refresh": 'refresh',
      "click #need-refresh": 'setRefresh',
      "click #extend-timespan": 'extendTimespan',
      "click #reset-timespan": 'resetTimespan'
    },
    refresh: function() {
      return this.model.forceUpdate();
    },
    setRefresh: function() {
      var needRefresh;
      needRefresh = this.$el.find('#need-refresh').is(":checked");
      this.model.setRefresh(needRefresh);
      return true;
    },
    extendTimespan: function() {
      var select, val;
      select = this.$el.find("#extend-timespan-val");
      val = select.first().val();
      return this.model.increaseTimespan(parseInt(val));
    },
    resetTimespan: function() {
      return this.model.resetTimespan();
    },
    renderChart: function() {
      return this.chartView.render();
    },
    updateChart: function() {
      return this.chartView.updateData(this.cutoffMin(), this.cutoffMax());
    },
    render: function() {
      this.$el.html(this.template(this.model.toJSON()));
      this.chartView = new WidgetChartView({
        model: this.model
      });
      this.$el.find("#plotarea").append(this.chartView.el);
      return this.$el.addClass("span" + (this.model.get('width')));
    },
    cutoffMin: function() {
      var val;
      val = parseFloat(this.controlValue('#cutoff-min'));
      if (_.isNaN(val)) {
        return null;
      } else {
        return val;
      }
    },
    cutoffMax: function() {
      var val;
      val = parseFloat(this.controlValue('#cutoff-max'));
      if (_.isNaN(val)) {
        return null;
      } else {
        return val;
      }
    },
    controlValue: function(id) {
      var val;
      return val = this.$el.find(id).first().val();
    }
  });
  widgetList = new WidgetList;
  widgetList.setContext(pageInfos);
  setInterval(function() {
    if (pageInfos.selected()) {
      return widgetList.each(function(w) {
        return w.refetch();
      });
    }
  }, 200);
  WidgetListView = Backbone.View.extend({
    initialize: function() {
      return widgetList.bind('reset', this.render, this);
    },
    render: function() {
      var container;
      container = $('#widgets');
      container.empty();
      return widgetList.each(function(w) {
        var view;
        view = new WidgetView({
          model: w
        });
        view.render();
        container.append(view.el);
        return view.renderChart();
      });
    }
  });
  widgetListApp = new WidgetListView;
  AppRouter = Backbone.Router.extend({
    initialize: function(pageInfos, widgetList) {
      this.pageInfos = pageInfos;
      this.widgetList = widgetList;
    },
    routes: {
      'pages/:id': 'getPage',
      'custom': 'custom',
      '*actions': 'defaultRoute'
    },
    getPage: function(ids) {
      var id;
      id = parseInt(ids);
      this.pageInfos.selectPage(id);
      return this.widgetList.fetch();
    },
    custom: function() {
      var dynamicWidget;
      this.pageInfos.selectNone();
      dynamicWidget = new DynamicWidgetView;
      return dynamicWidget.render($('#widgets'));
    },
    defaultRoute: function(actions) {
      if (this.pageInfos.length > 0) {
        return this.navigate('//pages/1');
      } else {
        return this.navigate('//custom');
      }
    }
  });
  appRouter = new AppRouter(pageInfos, widgetList);
  return Backbone.history.start();
};
