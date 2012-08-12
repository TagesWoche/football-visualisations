@tageswoche = @tageswoche || {}

tageswoche.tableData = do ->
  
    statistics: {}
    
    loadStatistics: (filter, callback) ->
      filterString = ""
      if filter.location then filterString += "location=#{filter.location}&"
      if filter.game then filterString += "game=#{filter.game}"
      if filterString == "" then filterString = "all"
      console.log("Filter is #{filterString}")
      if @statistics[filterString]
        callback(@statistics[filterString])
        return
      else
        $.ajax(
          url: "http://tageswoche.herokuapp.com/fcb/statistics?#{filterString}",
          dataType: "jsonp"
        ).done ( data ) =>
          console.log(data)
          @statistics[filterString] = data
          callback(data)
        return
      
    getStatisticsForPopup: ->
      @statistics["all"]