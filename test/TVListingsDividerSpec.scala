import org.specs2.mutable._
import org.specs2.runner._
import org.junit.runner._
import play.api.libs.json._
import play.api.test._
import play.api.test.Helpers._
import models.tvlistings.TVListingsDivider
import play.api.Play.current
import scala.xml.XML

@RunWith(classOf[JUnitRunner])
class TVListingsDividerSpec extends Specification {
  "TV" should {
    "チャンネル表分割正常終了" in new WithApplication{
      var listing = new TVListingsDivider("public/listings/BS.xml")
//      val channelNameList = listing.channelNameList
      listing.writeMultipleListing("public/listings/") mustEqual(true)
    }
  }
}
