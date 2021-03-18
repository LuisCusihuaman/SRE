job "fabio" {
  datacenters = ["dc1"]

  group "fabio" {
    count = 1
    
    task "fabio" {
      driver = "raw_exec"
      
      config {
        command = "fabio"
        args = ["-proxy.strategy=rr"]
      }
      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/v1.5.15/fabio-1.5.15-go1.15.5-linux_amd64"
        destination = "local/fabio"
        mode = "file"
      }
    }
  }
}
