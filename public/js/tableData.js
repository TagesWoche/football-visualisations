// Generated by CoffeeScript 1.3.3
(function() {

  this.tageswoche = this.tageswoche || {};

  tageswoche.tableData = (function() {
    var templates;
    templates = tageswoche.templates;
    return {
      statistics: {},
      filter: {},
      data: {},
      current: "top",
      init: function() {
        var _this = this;
        return this.loadStatistics(this.filter, function(data) {
          _this.data = data;
          _this.initEvents();
          return _this.showTopTable();
        });
      },
      getStatisticsForPopup: function() {
        return this.statistics["all"];
      },
      loadStatistics: function(filter, callback) {
        var filterString,
          _this = this;
        filterString = "";
        if (filter.location) {
          filterString += "location=" + filter.location + "&";
        }
        if (filter.game) {
          filterString += "game=" + filter.game;
        }
        if (filterString === "") {
          filterString = "all";
        }
        if (this.statistics[filterString]) {
          callback(this.statistics[filterString]);
        } else {
          $.ajax({
            url: "http://tageswoche.herokuapp.com/fcb/statistics?" + filterString,
            dataType: "jsonp"
          }).done(function(data) {
            _this.statistics[filterString] = data;
            return callback(data);
          });
        }
      },
      showTopTable: function() {
        this.current = "top";
        $("#stats").html(templates.table({
          players: this.data.list
        }));
        return this.tablesorter();
      },
      showGamesTable: function() {
        this.current = "games";
        $("#stats").html(templates.tableGames({
          players: this.data.list
        }));
        $(".gradesList").sparkline('html', {
          type: 'bar',
          height: 15,
          barWidth: 12,
          barSpacing: 2,
          colorMap: {
            "": '#F6F6F6',
            "0": '#F6F6F6',
            "0.01:1": '#E92431',
            "1.01:2": '#EB4828',
            "2.01:3": '#F9892E',
            "3.01:4": '#EAE600',
            "4.01:5": '#7FC249',
            "5.01:6": '#1BA755'
          }
        });
        return this.tablesorter();
      },
      tablesorter: function() {
        return $("#player-table").tablesorter({
          sortInitialOrder: "desc",
          rememberSorting: false
        });
      },
      initEvents: function() {
        var _this = this;
        return $("#stats").on("click", "td", function(event) {
          if ($(event.target).parent().parent("tbody").length) {
            if (_this.current === "top") {
              return _this.showGamesTable();
            } else {
              return _this.showTopTable();
            }
          }
        });
      },
      totals: function(players) {
        var count, gameGrade, gameGradeList, gameGradeSum, gameGrades, gradeSum, index, player, sum, _i, _j, _len, _len1, _ref;
        sum = {
          played: 0,
          minutes: 0,
          grades: [],
          goals: 0,
          assists: 0,
          yellowCards: 0,
          yellowRedCards: 0,
          redCards: 0,
          gameAverageGrades: []
        };
        gameGrades = [];
        for (_i = 0, _len = players.length; _i < _len; _i++) {
          player = players[_i];
          sum.played += +player.played;
          sum.minutes += +player.minutes;
          if (player.averageGrade > 0) {
            sum.grades.push(player.averageGrade);
          }
          sum.goals += +player.goals;
          sum.assists += +player.assists;
          sum.yellowCards += +player.yellowCards;
          sum.yellowRedCards += +player.yellowRedCards;
          sum.redCards += +player.redCards;
          _ref = player.grades;
          for (index in _ref) {
            gameGrade = _ref[index];
            if (gameGrades[index] === void 0) {
              gameGrades[index] = [];
            }
            gameGrades[index].push(gameGrade);
          }
        }
        gradeSum = _.reduce(sum.grades, function(sum, grade) {
          return sum += grade;
        }, 0);
        sum.averageGrade = tageswoche.tableData.round(gradeSum / sum.grades.length);
        for (_j = 0, _len1 = gameGrades.length; _j < _len1; _j++) {
          gameGradeList = gameGrades[_j];
          count = 0;
          gameGradeSum = _.reduce(gameGradeList, function(sum, grade) {
            if (grade > 0) {
              count += 1;
              return sum += grade;
            } else {
              return sum;
            }
          }, 0);
          if (count === 0) {
            sum.gameAverageGrades.push(0);
          } else {
            sum.gameAverageGrades.push(tageswoche.tableData.round(gameGradeSum / count));
          }
        }
        return sum;
      },
      aboveNull: function(value) {
        var number;
        number = +value;
        if (number && number > 0) {
          return number;
        } else {
          return "";
        }
      },
      round: function(value) {
        return Math.round(value * 10) / 10;
      },
      aboveNullRounded: function(value) {
        return this.aboveNull(this.round(value));
      }
    };
  })();

}).call(this);
