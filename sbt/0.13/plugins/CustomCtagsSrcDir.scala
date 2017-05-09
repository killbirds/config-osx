import sbt._
import Keys._
import net.ceedubs.sbtctags.CtagsKeys._

object CustomCtagsSrcDir extends Plugin {
  override def settings = Seq(
    dependencySrcUnzipDir := baseDirectory.value / ".ctags_srcs",
    ctagsSrcFileFilter := {
      ctagsSrcFileFilter.value - { n: String => 
        List(
          "sbt/",
          "scala/",
          "org/jboss/netty/",
          "org/scalatools/",
          "org/scalafmt",
          "org/scalameta",
          "org/aspectj/",
          "org/apache/tools/ant/",
          "org/apache/log4j/",
          "org/apache/ivy/",
          "org/specs2",
          "net/sf/cglib/",
          "ammonite/",
          "jline/",
          "junit/",
          "lombok/",
          "derive/",
          "fastparse/",
          "jawn/",
          "pprint/",
          "scalaparse/",
          "scopt/",
          "sourcecode/",
          "specs2",
          "upickle/"
        ).exists(n.startsWith)
      }
    }
  )
}
