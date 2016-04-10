package controllers

import play.api.Play.current
import play.api._
import play.api.mvc._
import play.api.libs.json._

//import play.api.db.slick._
//import models._

import java.util.Calendar
import java.util.TimeZone
import models.tvlistings.TVListings
import org.joda.time.DateTime

object Application extends Controller {
  def index = Action {
     Ok(views.html.tvlistings.render())
  }
  def testListings = Action {
     Ok(views.html.tvlistingsTest.render())
  }

  def getJSON = Action {
    val timeZoneJson = {
      val b = Map.newBuilder[String,String]
      TimeZone.getAvailableIDs().foreach{ timeZoneId =>
        val tz = TimeZone.getTimeZone(timeZoneId)
        b += tz.getDisplayName() -> tz.getID()
      }
      b.result
    }
    val jsonObject = Json.toJson(
        Map(
            "localDate" -> Json.toJson(Calendar.getInstance(TimeZone.getDefault()).getTime().toString()),
            "utcDate" -> Json.toJson(Calendar.getInstance(TimeZone.getTimeZone("UTC")).getTime().toString()),
            "timeZone" -> Json.toJson(timeZoneJson)
            )
    )
    Ok(jsonObject)
  }
  def getProgrammesJSON(year:String, monthOfYear:String, dayOfMonth:String, hourOfDay:String, minuteOfHour:String, length:String, broadcast:String, ch:String) = Action{
    val litings = new TVListings("public/listings/" + ch + ".xml")
    val start = new DateTime(year.toInt, monthOfYear.toInt, dayOfMonth.toInt, hourOfDay.toInt, minuteOfHour.toInt)
    val stop = start.plusMinutes(length.toInt)
    var programmeList:Seq[JsValue] = litings.programmeList(start, stop)
    Ok(Json.toJson(programmeList))
  }
  def getChannelNameJSON(ch:String) = Action{
    val litings = new TVListings("public/listings/" + ch + ".xml")
    Ok(Json.toJson(litings.channelName))
  }
  def reservationProgramme(year:String, monthOfYear:String, dayOfMonth:String, hourOfDay:String, minuteOfHour:String, length:String, broadcast:String, ch:String) = Action{
//    val litings = new TVListings("public/listings/" + ch + ".xml")
//    val start = new DateTime(year.toInt, monthOfYear.toInt, dayOfMonth.toInt, hourOfDay.toInt, minuteOfHour.toInt)
//    val stop = start.plusMinutes(length.toInt)
//    var programmeList:Seq[JsValue] = litings.programmeList(start, stop)
//    Ok(Json.toJson(programmeList))

    var outString = "Number is "
//    val conn = DB.getConnection()
//    try {
//      val stmt = conn.createStatement
//      val rs = stmt.executeQuery("SELECT 9 as testkey ")
//      while (rs.next()) {
//        outString += rs.getString("testkey")
//      }
//    } finally {
//      conn.close()
//    }
//    Ok(outString)


    Ok(outString)
  }

}
