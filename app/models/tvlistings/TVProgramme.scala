package models.tvlistings

import scala.xml.Node
import play.api.libs.json.Json
import play.api.libs.json.JsValue
import org.joda.time.format.DateTimeFormat;

class TVProgramme( programmeNode:Node) {
  var channel = programmeNode.\@("channel")
  var start = DateTimeFormat.forPattern("yyyyMMddHHmmss +0900").parseDateTime(programmeNode\@("start"))
  var stop = DateTimeFormat.forPattern("yyyyMMddHHmmss +0900").parseDateTime(programmeNode\@("stop"))
  var title = ""
  var desc = ""
  var category = ""
  for(childNode <- programmeNode.child; 
  if childNode.\("@lang").text.equals("ja_JP") 
  ){
	val label = childNode.label;
  	val text = childNode.text;
  	label match {
  	  case "title" => title = text
  	  case "desc" => desc = text
  	  case _ => 
  	}
  }
  for(childNode <- programmeNode.child; 
  if childNode.\("@lang").text.equals("en") 
  ){
	val label = childNode.label;
  	val text = childNode.text;
  	label match {
  	  case "category" => category = text
  	  case _ => 
  	}
  }

  def toJson:JsValue = {
    Json.toJson(
        Map(
            "channel" -> Json.toJson(channel),
            "start" -> Json.toJson(start),
            "stop" -> Json.toJson(stop),
            "title" -> Json.toJson(title),
            "desc" -> Json.toJson(desc),
            "category" -> Json.toJson(category)
        )
    )
  }
}