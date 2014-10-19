package xml

import play.api._
import org.joda.time.DateTime
import org.joda.time.format._
import scala.xml.XML
import scala.xml.Text
import scala.xml.Node
import scala.xml.Elem
import play.api.libs.json.Json
import play.api.libs.json.JsValue


class TVListings(filename:String) {
  private val xml = XML.loadFile(filename)

  def channelName : String = {
    xml.\\("tv").\("channel").\("display-name").filter(_.\("@lang").contains(Text("ja_JP"))).text
  }

  def numberOfProgramme : Integer ={
    xml.\\("tv").\("programme").size
  }

  def toJsonProgrammeList : JsValue ={
    val programmeList:Seq[JsValue] = Seq()
    val programmeNodeList = xml.\\("tv").\("programme")
    for(e <- programmeNodeList){
      var programme = new TVProgramme(e)
      programme.toJson +: programmeList
    }
    Json.toJson(programmeList)
  }

  def toJsonProgrammeList( start:DateTime, stop:DateTime): JsValue = {
    var programmeList:Seq[JsValue] = Seq()
    val programmeNodeList = xml.\\("tv").\("programme")
    for(e <- programmeNodeList){
      var programme = new TVProgramme(e)
      if((programme.start.isEqual(start) || programme.start.isAfter(start))
          && programme.start.isBefore(stop)){
    	  programmeList = programme.toJson +: programmeList
      }
    }
    Json.toJson(programmeList)
  }
// public static Result getProgrammesJSON(
//String year, String month, String day, String hour, String min, String length, String broadcast, String ch) {

}