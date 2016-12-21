library verilog;
use verilog.vl_types.all;
entity cpu_vlg_sample_tst is
    port(
        Clock           : in     vl_logic;
        Reset           : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end cpu_vlg_sample_tst;
