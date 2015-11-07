package controllers

import play.api._
import play.api.mvc._
import play.api.libs.json._
import java.util.Calendar
import java.util.TimeZone
import models.tvlistings.TVListings
import org.joda.time.DateTime

object Application extends Controller {
  def index = Action {
     Ok(views.html.tvlistings.render());
//    Ok(views.html.index("Your new application is ready."))
  }
  def testListings = Action {
     Ok(views.html.tvlistingsTest.render());
  }

  def nop = Action {
    Ok("")
  }

  def getJSON = Action {
    val timeZoneJson = {
      val b = Map.newBuilder[String,String]
      TimeZone.getAvailableIDs().foreach{ timeZoneId =>
        val tz = TimeZone.getTimeZone(timeZoneId);
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
    val start = new DateTime(year.toInt, monthOfYear.toInt, dayOfMonth.toInt, hourOfDay.toInt, minuteOfHour.toInt);
    val stop = start.plusMinutes(length.toInt);
    Ok(litings.toJsonProgrammeList(start, stop));
  }
  def getChannelNameJSON(ch:String) = Action{
    val litings = new TVListings("public/listings/" + ch + ".xml")
    Ok(Json.toJson(litings.channelName));
  }

}
