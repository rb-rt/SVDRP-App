import QtQuick

/**
  Für die Protokollierung beim Programmstart
  Model Rolen: message
  Model Rolen: time Wird automatisch hinzugefügt
  **/

ListModel {
    function addMessage(msg){
        var d = new Date()
        var s = Qt.formatTime(d, "mm:ss.zzz")
        append({ "message": msg, "time": s })
    }
}
