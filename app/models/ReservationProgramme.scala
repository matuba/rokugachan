package models
/*

import play.api.db.slick.Config.driver.simple._
import java.sql.{ Date, Timestamp }

//DTO
case class Reservation(
  id:String,
  start:Date,
  length:Long,
  broadcast:String,
  ch:String,
  tvTuner:String,
  created:Timestamp = new Timestamp(System.currentTimeMillis()))
}

//schema
class ReservationTable(tag: Tag) extends Table[Reservation](tag, "ReservationProgrammes") {
  def id = column[String]("ID", O.PrimaryKey)
  def start = column[Date]("START")
  def length = column[Long]("LENGTH")
  def broadcast = column[String]("BROADCAST")
  def ch = column[String]("CH")
  def tvTuner = column[String]("TVTUNER")
  def created = column[Timestamp]("CREATED")
  def * = (id, start, length, broadcast, ch, tvTuner, created) <> (Reservation.tupled, Reservation.unapply)
}
object ReservationDAO {
  lazy val reservationQuery = TableQuery[ReservationTable]

}
*/
