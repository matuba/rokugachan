import org.specs2.mutable._
import play.api.test._
import play.api.test.Helpers._
import org.junit.runner._
import play.api.libs.json._
import org.joda.time.DateTime
import models.tvlistings.TVListings
import models.tvlistings.TVListingsDivider
class TVListingsSpec extends Specification {
  "test.xmlを使用する" should {
     var listingsDivider = new TVListingsDivider("public/listings/test.xml")
     var listings = new TVListings("public/listings/test.xml")
     
//     "チャンネル名を取得できること" in {
//       listings.channelName mustEqual("NHK BS1 <test> ")
//     }

     "21時40分-21時45分は１番組" in {
      val start = new DateTime(2013, 9, 24, 21, 40, 0);
      val stop = new DateTime(2013, 9, 24, 21, 45, 0);
      val jsv = listings.toJsonProgrammeList(start, stop)
      
      val programmes = jsv.as[JsArray]
      programmes.value .length mustEqual(1)
     }
    "21時40分-21時46分は2番組" in {
      val start = new DateTime(2013, 9, 24, 21, 40, 0);
      val stop = new DateTime(2013, 9, 24, 21, 46, 0);
      val jsv = listings.toJsonProgrammeList(start, stop)
      
      val programmes = jsv.as[JsArray]
      programmes.value .length mustEqual(2)
    }
    "21時45分-21時46分は1番組" in {
      val start = new DateTime(2013, 9, 24, 21, 45, 0);
      val stop = new DateTime(2013, 9, 24, 21, 46, 0);
      val jsv = listings.toJsonProgrammeList(start, stop)
      
      val programmes = jsv.as[JsArray]
      programmes.value .length mustEqual(1)
    }

  }
}
