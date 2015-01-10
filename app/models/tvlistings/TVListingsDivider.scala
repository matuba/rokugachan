package models.tvlistings

import play.api._
import scala.xml.XML
import scala.xml.Text
import scala.xml.Node
import java.io.File
import java.io.PrintWriter
import java.io.IOException
//１ファイルに複数チャンネル情報が含まれる場合
//１チャンネル1ファイルになるよう分割してファイル出力する
class TVListingsDivider(filename:String) {
  private val xml = XML.loadFile(filename)

  private def createHeaderXML(id:String): String  = {
    var headerXML = new StringBuilder 
    headerXML.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
	headerXML.append("<!DOCTYPE tv SYSTEM \"xmltv.dtd\">\n");
	headerXML.append("\n");
	headerXML.append("<tv generator-info-name=\"tsEPG2xml\" generator-info-url=\"http://localhost/\">\n");
	headerXML.append("  <channel id=\"");
	headerXML.append(id);
	headerXML.append("\">\n");	
	val displayName = xml.\\("tv").\("channel").filter(_.\("@id").contains(Text(id))).\("display-name").filter(_.\("@lang").contains(Text("ja_JP"))).text
	headerXML.append("    <display-name lang=\"ja_JP\">" + displayName + "</display-name>\n");
	headerXML.append("  </channel>\n");	
	headerXML.result
  }
  private def createFooterXML ={
    var footerXML = new StringBuilder 
    footerXML.append("</tv>");
    footerXML.result
  }
  private def createProgrammeListXML(id:String): String = {
    var programmesXML = new StringBuilder 
    val elements = xml.\\("tv").\("programme").filter(_.\("@channel").contains(Text(id)))
    for(e <- elements) programmesXML.append(createProgrammeXML(e))
    programmesXML.result
  }
  private def createProgrammeXML( programmeNode:Node): String = {
    var programmeXml = new StringBuilder 
    val channel = programmeNode\("@channel")
    val start = programmeNode.\("@start")
    val stop = programmeNode.\("@stop")
	programmeXml.append("  <programme ");
	programmeXml.append("start=\"").append(start).append("\" ");
	programmeXml.append("stop=\"").append(stop).append("\" ");
	programmeXml.append("channel=\"").append(channel).append("\" ");
	programmeXml.append(">\n");
	
	for(childNode <- programmeNode.child;
	    if childNode.label.equals("title") 
	    || childNode.label.equals("desc") 
	    || childNode.label.equals("category")){
	  val label = childNode.label
	  val text = scala.xml.Utility.escape(childNode.text)
	  var lang = "ja_JP"
	  if(!childNode.\("@lang").isEmpty){
	    lang = childNode.\("@lang").text
	  }
	  programmeXml.append("    <")
	  programmeXml.append(label)
	  programmeXml.append(" lang=\"")
	  programmeXml.append(lang)
	  programmeXml.append("\">")
	  programmeXml.append(text)
	  programmeXml.append("</")
	  programmeXml.append(label)
	  programmeXml.append(">\n")
	}
	programmeXml.append("  </programme>\n");
    programmeXml.result
  }
  private def channelIDList : Seq[String] = {
    xml \\ "tv" \ "channel" map(_.\("@id").text)
  }
  private def writeListingXML(filename : String, channelname : String) : Boolean = {
    var fileOutput = new StringBuilder
    fileOutput.append(createHeaderXML(channelname))
    fileOutput.append(createProgrammeListXML(channelname))
    fileOutput.append(createFooterXML)

    var pw:PrintWriter = null
    try{
      pw = new PrintWriter(filename)
      pw.write(fileOutput.toString());
    }
    catch {
      case e:IOException => println(e)
      return false
    }
    finally {
	    pw.close()
    }
    return true
  }
  def writeMultipleListing(filepath : String) : Boolean = {
    channelIDList.foreach(channelname=>{
      if(!writeListingXML( filepath + channelname + ".xml", channelname))
        return false
    })
    return true
  }

}