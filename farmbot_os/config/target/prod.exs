use Mix.Config

config :farmbot_core, :behaviour,
  firmware_handler: Farmbot.Firmware.StubHandler,
  leds_handler: Farmbot.Target.Leds.AleHandler,
  pin_binding_handler: Farmbot.Target.PinBinding.AleHandler,
  celery_script_io_layer: Farmbot.OS.IOLayer


data_path = Path.join("/", "root")
config :farmbot_ext,
  data_path: data_path

config :farmbot_core, Farmbot.Config.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: Path.join(data_path, "config-#{Mix.env()}.sqlite3")

config :farmbot_core, Farmbot.Logger.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: Path.join(data_path, "logs-#{Mix.env()}.sqlite3")

config :farmbot_core, Farmbot.Asset.Repo,
  adapter: Sqlite.Ecto2,
  loggers: [],
  database: Path.join(data_path, "repo-#{Mix.env()}.sqlite3")

config :farmbot_os,
  ecto_repos: [Farmbot.Config.Repo, Farmbot.Logger.Repo, Farmbot.Asset.Repo],
  init_children: [
    {Farmbot.Target.Leds.AleHandler, []},
    {Farmbot.Firmware.UartHandler.AutoDetector, []},
  ],
  platform_children: [
    {Farmbot.Target.Bootstrap.Configurator, []},
    {Farmbot.Target.Network, []},
    {Farmbot.Target.SSHConsole, []},
    {Farmbot.Target.Network.WaitForTime, []},
    {Farmbot.Target.Network.DnsTask, []},
    {Farmbot.Target.Network.TzdataTask, []},
    # Reports Disk usage every 60 seconds.
    {Farmbot.Target.DiskUsageWorker, []},
    # Reports Memory usage every 60 seconds.
    {Farmbot.Target.MemoryUsageWorker, []},
    # Reports SOC temperature every 60 seconds.
    {Farmbot.Target.SocTempWorker, []},
    # Reports Uptime every 60 seconds.
    {Farmbot.Target.UptimeWorker, []},
    {Farmbot.Target.Network.InfoSupervisor, []},
    {Farmbot.Target.Uevent.Supervisor, []},
  ]

config :farmbot_os, :behaviour,
  system_tasks: Farmbot.Target.SystemTasks


config :farmbot_os, Farmbot.System.NervesHub,
  farmbot_nerves_hub_handler: Farmbot.System.NervesHubClient

config :nerves_hub,
  client: Farmbot.System.NervesHubClient,
  public_keys: [File.read!("priv/staging.pub"), File.read!("priv/prod.pub")]

config :nerves_hub, NervesHub.Socket, [
  reconnect_interval: 5_000,
]