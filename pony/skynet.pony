use "collections"
use "time"

actor Main is Aggregator
  let _env: Env
  let _start: U64 = Time.nanos()
  
  new create(env: Env) =>
    _env = env
    Skynet(this, 0, 1_000_000, 10)

  be accept(value: U64) =>
    let duration = (Time.nanos() - _start).f32() / 1_000_000
    
    let summary = recover String end
    summary.append("Result: ")
    summary.append(value.string())
    summary.append(" in ")
    summary.append(duration.string(FormatSettingsFloat.set_format(FormatFix).set_precision(3)))
    summary.append(" ms")

    _env.out.print(consume summary)


actor Skynet is Aggregator
  var _div: U64 = 0
  var _total_sum: U64 = 0
  let _parent: Aggregator

  new create(parent: Aggregator, num: U64, size: U64, div: U64) =>
    _parent = parent
    _div = div

    if size == 1 then
      parent.accept(num)
    else
      for i in Range[U64](0, div) do
        let sub_num = num + (i * (size / div))
        Skynet(this, sub_num, size / div, div)
      end
    end

  be accept(value: U64) =>
    _total_sum = _total_sum + value
    _div = _div - 1

    if _div == 0 then
      _parent.accept(_total_sum)
    end

interface tag Aggregator
  be accept(value: U64)