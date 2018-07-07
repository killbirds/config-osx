//resolvers += "Artima Maven Repository" at "http://repo.artima.com/releases"

//libraryDependencies += "com.lihaoyi" % "ammonite-repl" % "0.5.7" % "test" cross CrossVersion.full
//initialCommands in (Test, console) := """ammonite.repl.Main.run("")"""

wartremoverWarnings in (Compile, compile) ++= Warts.unsafe

//wartremoverWarnings in (Compile, compile) ++= Warts.allBut(Wart.Overloading, Wart.Equals, Wart.Nothing)
