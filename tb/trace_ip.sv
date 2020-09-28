//#############################################################################
//#
//# Copyright 2020 Thales
//#
//# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
//# you may not use this file except in compliance with the License.
//# You may obtain a copy of the License at
//#
//#     https://solderpad.org/licenses/
//#
//# Unless required by applicable law or agreed to in writing, software
//# distributed under the License is distributed on an "AS IS" BASIS,
//# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//# See the License for the specific language governing permissions and
//# limitations under the License.
//#
//#############################################################################
//#
//# Original Author: Jean-Roch COULON (jean-roch.coulon@invia.fr)
//#
//#############################################################################

import ariane_pkg::*;

module trace_ip #(
  parameter bit          InclSimDTM = 1'b0,
  parameter int unsigned SIM_FINISH = 1000000
)(
  input logic [31:0]                    cycles
);

  // synthesis translate_off

  int f;
  logic [31:0] cycles_to_print;
  logic [63:0] pc64;
  logic [riscv::PLEN-1:0] address_host;
  logic [63:0] data_host;

  initial begin
    f = $fopen("trace_ip.dasm", "w");
  end

  always_ff @(posedge i_ariane.clk_i or negedge i_ariane.rst_ni) begin
    if (~i_ariane.rst_ni) begin
    end else begin
      string mode = "";
      if (i_ariane.debug_mode) mode = "D";
      else begin
        case (i_ariane.priv_lvl)
        riscv::PRIV_LVL_M: mode = "M";
        riscv::PRIV_LVL_S: mode = "S";
        riscv::PRIV_LVL_U: mode = "U";
        endcase
      end
      for (int i = 0; i < NR_COMMIT_PORTS; i++) begin
        pc64 = {{64-riscv::VLEN{1'b0}}, i_ariane.commit_instr_id_commit[i].pc};
        if (i_ariane.commit_ack[i] && !i_ariane.commit_instr_id_commit[i].ex.valid) begin
          $fwrite(f, "%d core   0: 0x%h (0x%h) DASM(%h)\n",
                cycles_to_print,
                pc64,
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0],
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0]);
          if (ariane_pkg::is_rd_fpr(i_ariane.commit_instr_id_commit[i].op) == 0)
            if (i_ariane.commit_instr_id_commit[i].rd[4:0] == 0)
              $fwrite(f, "%h 0x%h (0x%h)\n",
                i_ariane.priv_lvl,
                pc64,
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0]);
            else
              $fwrite(f, "%h 0x%h (0x%h) x%d 0x%h\n",
                i_ariane.priv_lvl,
                pc64,
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0],
                i_ariane.commit_instr_id_commit[i].rd[4:0],
                i_ariane.wdata_commit_id[i][riscv::XLEN-1:0]);
          else
            $fwrite(f, "%h 0x%h (0x%h) f%d 0x%h\n",
              i_ariane.priv_lvl,
              pc64,
              i_ariane.commit_instr_id_commit[i].ex.tval[31:0],
              i_ariane.commit_instr_id_commit[i].rd[4:0],
              i_ariane.commit_instr_id_commit[i].result[riscv::XLEN-1:0]);
        end else if (i_ariane.commit_instr_id_commit[i].valid && i_ariane.commit_instr_id_commit[i].ex.valid && i_ariane.ex_commit.valid) begin
          if (i_ariane.commit_instr_id_commit[i].ex.cause == 2) begin
          end else begin
            if (i_ariane.debug_mode) begin
              $fwrite(f,"%d 0x%0h %s (0x%h) DASM(%h)\n", cycles_to_print, pc64, mode, i_ariane.commit_instr_id_commit[i].ex.tval[31:0], i_ariane.commit_instr_id_commit[i].ex.tval[31:0]);
            end else if (i_ariane.commit_instr_id_commit[i].ex.cause != 24) begin
              $fwrite(f, "%d core   0: 0x%h (0x%h) DASM(%h)\n",
                cycles_to_print,
                pc64,
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0],
                i_ariane.commit_instr_id_commit[i].ex.tval[31:0]);
              $fwrite(f, "core   0: exception %5d, epc 0x%h\n", i_ariane.commit_instr_id_commit[i].ex.cause, pc64);
            end
          end
        end
      end
      cycles_to_print <= cycles;
      if (cycles > SIM_FINISH) $finish(1);
      if (i_ariane.ex_stage_i.lsu_i.dcache_req_ports_o[2].data_req) begin
        address_host={i_ariane.ex_stage_i.lsu_i.dcache_req_ports_o[2].address_tag[DCACHE_TAG_WIDTH-1:0],
                      i_ariane.ex_stage_i.lsu_i.dcache_req_ports_o[2].address_index[DCACHE_INDEX_WIDTH-1:0]};
        data_host=i_ariane.ex_stage_i.lsu_i.dcache_req_ports_o[2].data_wdata[63:0];
        if (address_host=='h80001000 && !InclSimDTM) begin
          $fwrite(f, "write to host addr=%h data=%h\n", address_host, data_host);
          $finish();
          $finish();
        end
      end
    end
  end

  final begin
    $fclose(f);
  end

  // synthesis translate_on

endmodule // trace_ip

