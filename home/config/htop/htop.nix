{
  enable = true;
  fields = [
    "PID"
    "USER"
    # "PRIORITY"
    "NICE"
    "IO_PRIORITY"
    # "IO_WRITE_RATE"
    # "IO_READ_RATE"
    "IO_RATE"
    "STATE"
    "NLWP"
    "PERCENT_CPU"
    "PERCENT_MEM"
    # "RCHAR"
    # "WCHAR"
    "TIME"
    "OOM"
    "COMM"
  ];
  cpuCountFromZero = true;
  hideThreads = true;
  hideUserlandThreads = true;
  highlightBaseName = true;
  meters = {
    left = [
      "AllCPUs"
      "Blank"
      {
        kind = "CPU";
        mode = 3;
      }
      "Blank"
      "LoadAverage"
      "Tasks"
    ];
    right = [
      {
        kind = "Memory";
        mode = 3;
      }
      {
        kind = "Memory";
        mode = 2;
      }
      "Blank"
      {
        kind = "Swap";
        mode = 3;
      }
      {
        kind = "Swap";
        mode = 2;
      }
      "Blank"
      "Uptime"
    ];
  };
  showProgramPath = false;
  updateProcessNames = true;
  vimMode = true;
}
