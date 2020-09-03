//#############################################################################
//#
//# Original Author: Jean-Roch COULON (jean-roch.coulon@invia.fr)
//#                  André Sintzoff (andre.sintzoff@gemalto.com)
//#
//#############################################################################

import ariane_pkg::*;
import wt_cache_pkg::*;
import dm::*;

module debug_ip #(
  parameter int unsigned DEBUG_START = 0,
  parameter int unsigned DEBUG_STOP  = 0
)(
  input logic [31:0]                    cycles
);

// synthesis translate_off
`ifndef VERILATOR


  typedef struct packed {
    logic [1:0]                   irq_i;
    logic                         ipi_i;
    logic                         time_irq_i;
    logic                         debug_req_i;
    ariane_axi::resp_t            axi_resp_i;
  } trace_ariane_structsi_t;
  typedef struct packed {
    ariane_axi::req_t             axi_req_o;
  } trace_ariane_structso_t;

  typedef struct packed {
      logic                      debug_mode_i;
      ariane_pkg::fu_data_t      fu_data_i;
      logic [riscv::VLEN-1:0]    pc_i;
      logic                      is_compressed_instr_i;
      logic                      fu_valid_i;
      logic                      branch_valid_i;
      logic                      branch_comp_res_i;
      ariane_pkg::branchpredict_sbe_t        branch_predict_i;
  } trace_branch_structsi_t;

  typedef struct packed {
     logic [riscv::VLEN-1:0]    branch_result_o;
     ariane_pkg::bp_resolve_t   resolved_branch_o;
     logic                      resolve_branch_o;
     ariane_pkg::exception_t    branch_exception_o;
  } trace_branch_structso_t;

  typedef struct packed {
      logic                                    halt_i;
      logic                                    flush_dcache_i;
      logic                                    single_step_i;
      scoreboard_entry_t [NR_COMMIT_PORTS-1:0] commit_instr_i;
      amo_resp_t                               amo_resp_i;
      logic [riscv::XLEN-1:0]                  csr_rdata_i;
      exception_t                              csr_exception_i;
      logic                                    commit_lsu_ready_i;
      logic                                    no_st_pending_i;
  } trace_commit_structsi_t;

  typedef struct packed {
     exception_t                              exception_o;
     logic                                    dirty_fp_state_o;
     logic [NR_COMMIT_PORTS-1:0]              commit_ack_o;
     logic [NR_COMMIT_PORTS-1:0][4:0]         waddr_o;
     logic [NR_COMMIT_PORTS-1:0][riscv::XLEN-1:0] wdata_o;
     logic [NR_COMMIT_PORTS-1:0]              we_gpr_o;
     logic [NR_COMMIT_PORTS-1:0]              we_fpr_o;
     logic [riscv::VLEN-1:0]                  pc_o;
     fu_op                                    csr_op_o;
     logic [riscv::XLEN-1:0]                  csr_wdata_o;
     logic                                    csr_write_fflags_o;
     logic                                    commit_lsu_o;
     logic                                    amo_valid_commit_o;
     logic                                    commit_csr_o;
     logic                                    fence_i_o;
     logic                                    fence_o;
     logic                                    flush_commit_o;
     logic                                    sfence_vma_o;
  } trace_commit_structso_t;

  typedef struct packed {
      logic            flush_dcache_ack_i;     
      logic            halt_csr_i;             
      logic            eret_i;                 
      logic            ex_valid_i;             
      logic            set_debug_pc_i;         
      bp_resolve_t     resolved_branch_i;      
      logic            flush_csr_i;            
      logic            fence_i_i;              
      logic            fence_i;                
      logic            sfence_vma_i;           
      logic            flush_commit_i;          
      logic            flush_unissued_instr_o;
  } trace_controller_structsi_t;

  typedef struct packed {
      logic                  time_irq_i;                 
      scoreboard_entry_t [NR_COMMIT_PORTS-1:0] commit_instr_i; 
      logic [NR_COMMIT_PORTS-1:0]              commit_ack_i;   
      logic  [63:0]          boot_addr_i;                
      logic  [63:0]          hart_id_i;                  
      exception_t            ex_i;                       
      fu_op                  csr_op_i;                   
      logic  [11:0]          csr_addr_i;                 
      logic  [63:0]          csr_wdata_i;                
      logic                  dirty_fp_state_i;           
      logic                  csr_write_fflags_i;         
      logic[riscv::VLEN-1:0] pc_i;                       
      logic [1:0]            irq_i;                      
      logic                  ipi_i;                      
      logic                  debug_req_i;                
      logic  [63:0]          perf_data_i;                
  } trace_csr_regfile_structsi_t;

  typedef struct packed {
     logic                  flush_o;
     logic                  halt_csr_o;                 
     logic  [63:0]          csr_rdata_o;                
     exception_t            csr_exception_o;                        
     logic[riscv::VLEN-1:0] epc_o;                      
     logic                  eret_o;                     
     logic[riscv::VLEN-1:0] trap_vector_base_o;         
     riscv::priv_lvl_t      priv_lvl_o;                 
     riscv::xs_t            fs_o;                       
     logic [4:0]            fflags_o;                   
     logic [2:0]            frm_o;                      
     logic [6:0]            fprec_o;                    
     irq_ctrl_t             irq_ctrl_o;                 
     logic                  en_translation_o;           
     logic                  en_ld_st_translation_o;     
     riscv::priv_lvl_t      ld_st_priv_lvl_o;           
     logic                  sum_o;
     logic                  mxr_o;
     logic[riscv::PPNW-1:0] satp_ppn_o;
     logic [ASID_WIDTH-1:0] asid_o;
     logic                  set_debug_pc_o;
     logic                  tvm_o;                      
     logic                  tw_o;                       
     logic                  tsr_o;                      
     logic                  debug_mode_o;               
     logic                  single_step_o;              
     logic                  icache_en_o;                
     logic                  dcache_en_o;                
     logic  [4:0]           perf_addr_o;                
     logic  [63:0]          perf_data_o;                
     logic                  perf_we_o;
  } trace_csr_regfile_structso_t;

  typedef struct packed {
      logic                                   flush_i;
      scoreboard_entry_t                      issue_instr_i;
      logic                                   issue_instr_valid_i;
      logic [63:0]                            rs1_i;
      logic                                   rs1_valid_i;
      logic [63:0]                            rs2_i;
      logic                                   rs2_valid_i;
      logic [FLEN-1:0]                        rs3_i;
      logic                                   rs3_valid_i;
      fu_t [2**REG_ADDR_SIZE-1:0]             rd_clobber_gpr_i;
      fu_t [2**REG_ADDR_SIZE-1:0]             rd_clobber_fpr_i;
      logic                                   flu_ready_i;
      logic                                   lsu_ready_i;
      logic                                   fpu_ready_i;
      logic [NR_COMMIT_PORTS-1:0][4:0]        waddr_i;
      logic [NR_COMMIT_PORTS-1:0][63:0]       wdata_i;
      logic [NR_COMMIT_PORTS-1:0]             we_gpr_i;
      logic [NR_COMMIT_PORTS-1:0]             we_fpr_i;
  } trace_issue_read_operands_structsi_t;

  typedef struct packed {
     logic                                   issue_ack_o;
     logic [REG_ADDR_SIZE-1:0]               rs1_o;
     logic [REG_ADDR_SIZE-1:0]               rs2_o;
     logic [REG_ADDR_SIZE-1:0]               rs3_o;
     fu_data_t                               fu_data_o;
     logic [riscv::VLEN-1:0]                 pc_o;
     logic                                   is_compressed_instr_o;
     logic                                   alu_valid_o;
     logic                                   branch_valid_o;
     branchpredict_sbe_t                     branch_predict_o;
     logic                                   lsu_valid_o;
     logic                                   mult_valid_o;
     logic                                   fpu_valid_o;
     logic [1:0]                             fpu_fmt_o;
     logic [2:0]                             fpu_rm_o;
     logic                                   csr_valid_o;
  } trace_issue_read_operands_structso_t;

  typedef struct packed {
      logic                                     flush_unissued_instr_i;
      logic                                     flush_i;
      scoreboard_entry_t                        decoded_instr_i;
      logic                                     decoded_instr_valid_i;
      logic                                     is_ctrl_flow_i;
      logic                                     flu_ready_i;
      logic                                     resolve_branch_i;
      logic                                     lsu_ready_i;
      logic                                     fpu_ready_i;
      logic [NR_WB_PORTS-1:0][TRANS_ID_BITS-1:0] trans_id_i;
      bp_resolve_t                              resolved_branch_i;
      logic [NR_WB_PORTS-1:0][riscv::XLEN-1:0]  wbdata_i;
      exception_t [NR_WB_PORTS-1:0]             ex_ex_i;
      logic [NR_WB_PORTS-1:0]                   wt_valid_i;
      logic [NR_COMMIT_PORTS-1:0][4:0]          waddr_i;
      logic [NR_COMMIT_PORTS-1:0][riscv::XLEN-1:0] wdata_i;
      logic [NR_COMMIT_PORTS-1:0]               we_gpr_i;
      logic [NR_COMMIT_PORTS-1:0]               we_fpr_i;
      logic [NR_COMMIT_PORTS-1:0]               commit_ack_i;
  } trace_issue_stage_structsi_t;

  typedef struct packed {
     logic                                     sb_full_o;
     logic                                     decoded_instr_ack_o;
     fu_data_t                                 fu_data_o;
     logic [riscv::VLEN-1:0]                   pc_o;
     logic                                     is_compressed_instr_o;
     logic                                     alu_valid_o;
     logic                                     lsu_valid_o;
     logic                                     branch_valid_o;
     branchpredict_sbe_t                       branch_predict_o;
     logic                                     mult_valid_o;
     logic                                     fpu_valid_o;
     logic [1:0]                               fpu_fmt_o;
     logic [2:0]                               fpu_rm_o;
     logic                                     csr_valid_o;
     scoreboard_entry_t [NR_COMMIT_PORTS-1:0]  commit_instr_o;
  } trace_issue_stage_structso_t;

  typedef struct packed {
     logic                     flush_i;
     logic                     amo_valid_commit_i;
     fu_data_t                 fu_data_i;
     logic                     lsu_valid_i;              
     logic                     commit_i;                 
     logic                     enable_translation_i;     
     logic                     en_ld_st_translation_i;   
     icache_areq_o_t           icache_areq_i;
     riscv::priv_lvl_t         priv_lvl_i;               
     riscv::priv_lvl_t         ld_st_priv_lvl_i;         
     logic                     sum_i;                    
     logic                     mxr_i;                    
     logic [riscv::PPNW-1:0]   satp_ppn_i;
     logic [ASID_WIDTH-1:0]    asid_i;                   
     logic                     flush_tlb_i;
     dcache_req_o_t [2:0]      dcache_req_ports_i;
     amo_resp_t                amo_resp_i;
  } trace_load_store_structsi_t;

  typedef struct packed {
     logic                     no_st_pending_o;
     logic                     lsu_ready_o;
     logic [TRANS_ID_BITS-1:0] load_trans_id_o;
     logic [riscv::XLEN-1:0]   load_result_o;
     logic                     load_valid_o;
     exception_t               load_exception_o;
     logic [TRANS_ID_BITS-1:0] store_trans_id_o;
     logic [riscv::XLEN-1:0]   store_result_o;
     logic                     store_valid_o;
     exception_t               store_exception_o;
     logic                     commit_ready_o;
     icache_areq_i_t           icache_areq_o;
     logic                     itlb_miss_o;
     logic                     dtlb_miss_o;
     dcache_req_i_t [2:0]      dcache_req_ports_o;
     amo_req_t                 amo_req_o;
  } trace_load_store_structso_t;

  typedef struct packed {
      logic      flush_i;
      lsu_ctrl_t lsu_req_i;
      logic      lus_req_valid_i;
      logic      pop_ld_i;
      logic      pop_st_i;
  } trace_lsu_bypass_structsi_t;

  typedef struct packed {
      lsu_ctrl_t lsu_ctrl_o;
      logic      ready_o;
  } trace_lsu_bypass_structso_t;

  typedef struct packed {
     logic                            flush_i;
     logic                            enable_translation_i;
     logic                            en_ld_st_translation_i;   
     icache_areq_o_t                  icache_areq_i;
     exception_t                      misaligned_ex_i;
     logic                            lsu_req_i;        
     logic [riscv::VLEN-1:0]          lsu_vaddr_i;      
     logic                            lsu_is_store_i;   
     riscv::priv_lvl_t                priv_lvl_i;
     riscv::priv_lvl_t                ld_st_priv_lvl_i;
     logic                            sum_i;
     logic                            mxr_i;
     logic [riscv::PPNW-1:0]          satp_ppn_i;
     logic [ASID_WIDTH-1:0]           asid_i;
     logic                            flush_tlb_i;
     dcache_req_o_t                   req_port_i;
  } trace_mmu_structsi_t;

  typedef struct packed {
     icache_areq_i_t                  icache_areq_o;
     logic                            lsu_dtlb_hit_o;
     logic                            lsu_valid_o;
     logic [riscv::PLEN-1:0]          lsu_paddr_o;
     exception_t                      lsu_exception_o;
     logic                            itlb_miss_o;
     logic                            dtlb_miss_o;
     dcache_req_i_t                   req_port_o;
  } trace_mmu_structso_t;

  typedef struct packed {
     logic                     flush_i;
     logic                     valid_i;
     lsu_ctrl_t                lsu_ctrl_i;
     logic                     commit_i;
     logic                     amo_valid_commit_i;
     logic [riscv::PLEN-1:0]   paddr_i;
     exception_t               ex_i;
     logic                     dtlb_hit_i;
     logic [11:0]              page_offset_i;
     amo_resp_t                amo_resp_i;
     dcache_req_o_t            req_port_i;
  } trace_store_structsi_t;

  typedef struct packed {
     logic                     no_st_pending_o;
     logic                     pop_st_o;
     logic                     commit_ready_o;
     logic                     valid_o;
     logic [TRANS_ID_BITS-1:0] trans_id_o;
     logic [63:0]              result_o;
     exception_t               ex_o;
     logic                     translation_req_o;
     logic [riscv::VLEN-1:0]   vaddr_o;
     logic                     page_offset_matches_o;
     amo_req_t                 amo_req_o;
     dcache_req_i_t            req_port_o;
  } trace_store_structso_t;

  typedef struct packed {
    logic                   flush_i;
    logic                   flush_bp_i;
    logic                   debug_mode_i;
    logic [63:0]            boot_addr_i;
    bp_resolve_t            resolved_branch_i;
    logic                   set_pc_commit_i;
    logic [riscv::VLEN-1:0] pc_commit_i;
    logic [riscv::VLEN-1:0] epc_i;
    logic                   eret_i;
    logic [riscv::VLEN-1:0] trap_vector_base_i;
    logic                   ex_valid_i;
    logic                   set_debug_pc_i;
    icache_dreq_o_t         icache_dreq_i;
    logic                   fetch_entry_ready_i;
  } trace_frontend_structsi_t;

  typedef struct packed {
   icache_dreq_i_t         icache_dreq_o;
   fetch_entry_t           fetch_entry_o;
   logic                   fetch_entry_valid_o;
  } trace_frontend_structso_t;

  typedef struct packed {
    logic                           icache_en_i;        
    logic                           icache_flush_i;         
    icache_areq_i_t                 icache_areq_i;          
    icache_dreq_i_t                 icache_dreq_i;          
    logic                           dcache_enable_i;        
    logic                           dcache_flush_i;         
    amo_req_t                       dcache_amo_req_i;
    dcache_req_i_t   [2:0]          dcache_req_ports_i;     
    ariane_axi::resp_t              axi_resp_i;
  } trace_wt_cache_structsi_t;

  typedef struct packed {
    logic                           icache_miss_o;
    icache_areq_o_t                 icache_areq_o;
    icache_dreq_o_t                 icache_dreq_o;
    logic                           dcache_flush_ack_o;
    logic                           dcache_miss_o;
    amo_resp_t                      dcache_amo_resp_o;
    dcache_req_o_t   [2:0]          dcache_req_ports_o;
    logic                           wbuffer_empty_o;
    ariane_axi::req_t               axi_req_o;
  } trace_wt_cache_structso_t;

  typedef struct packed {
    logic                           flush_i;
    logic                           en_i;
    icache_areq_i_t                 areq_i;
    icache_dreq_i_t                 dreq_i;
    logic                           mem_rtrn_vld_i;
    wt_cache_pkg::icache_rtrn_t     mem_rtrn_i;
    logic                           mem_data_ack_i;
  } trace_wt_icache_structsi_t;

  typedef struct packed {
    logic                           miss_o;
    icache_dreq_o_t                 dreq_o;
    logic                           mem_data_req_o;
    wt_cache_pkg::icache_req_t      mem_data_o;
  } trace_wt_icache_structso_t;

  localparam NumPorts = 3;
  typedef struct packed {
    logic                                       flush_i;          
    logic                                       wbuffer_empty_i;
    amo_req_t                                   amo_req_i;
    logic [NumPorts-1:0]                        miss_req_i;
    logic [NumPorts-1:0]                        miss_nc_i;
    logic [NumPorts-1:0]                        miss_we_i;
    logic [NumPorts-1:0][63:0]                  miss_wdata_i;
    logic [NumPorts-1:0][riscv::PLEN-1:0]       miss_paddr_i;
    logic [NumPorts-1:0][DCACHE_SET_ASSOC-1:0]  miss_vld_bits_i;
    logic [NumPorts-1:0][2:0]                   miss_size_i;
    logic [NumPorts-1:0][CACHE_ID_WIDTH-1:0]    miss_id_i;
    logic [DCACHE_MAX_TX-1:0][riscv::PLEN-1:0]  tx_paddr_i;
    logic [DCACHE_MAX_TX-1:0]                   tx_vld_i;
    logic                                       mem_rtrn_vld_i;
    dcache_rtrn_t                               mem_rtrn_i;
    logic                                       mem_data_ack_i;
  } trace_wt_dcache_missunit_structsi_t;
  typedef struct packed {
   logic                                       flush_ack_o; 
   logic                                       miss_o;      
   logic                                       cache_en_o;  
   amo_resp_t                                  amo_resp_o;
   logic [NumPorts-1:0]                        miss_ack_o;
   logic [NumPorts-1:0]                        miss_replay_o;
   logic [NumPorts-1:0]                        miss_rtrn_vld_o;
   logic [CACHE_ID_WIDTH-1:0]                  miss_rtrn_id_o;     
   logic                                       wr_cl_vld_o;        
   logic                                       wr_cl_nc_o;         
   logic [DCACHE_SET_ASSOC-1:0]                wr_cl_we_o;         
   logic [DCACHE_TAG_WIDTH-1:0]                wr_cl_tag_o;
   logic [DCACHE_CL_IDX_WIDTH-1:0]             wr_cl_idx_o;
   logic [DCACHE_OFFSET_WIDTH-1:0]             wr_cl_off_o;
   logic [DCACHE_LINE_WIDTH-1:0]               wr_cl_data_o;
   logic [DCACHE_LINE_WIDTH/8-1:0]             wr_cl_data_be_o;
   logic [DCACHE_SET_ASSOC-1:0]                wr_vld_bits_o;
   logic                                       mem_data_req_o;
   dcache_req_t                                mem_data_o;
  } trace_wt_dcache_missunit_structso_t;

  typedef struct packed {
    logic                 icache_data_req_i;
    icache_req_t          icache_data_i;
    logic                 dcache_data_req_i;
    dcache_req_t          dcache_data_i;
    ariane_axi::resp_t   axi_resp_i;
  } trace_wt_axi_adapter_structsi_t;
  typedef struct packed {
    logic                 icache_data_ack_o;
    logic                 icache_rtrn_vld_o;
    icache_rtrn_t         icache_rtrn_o;
    logic                 dcache_data_ack_o;
    logic                 dcache_rtrn_vld_o;
    dcache_rtrn_t         dcache_rtrn_o;
    ariane_axi::req_t    axi_req_o;
  } trace_wt_axi_adapter_structso_t;

  typedef struct packed {
    logic                            cache_en_i;
    dcache_req_i_t                   req_port_i;
    logic                            miss_ack_i;
    logic                            miss_replay_i;   
    logic                            miss_rtrn_vld_i; 
    logic                            wr_cl_vld_i;
    logic                            rd_ack_i;
    logic [63:0]                     rd_data_i;
    logic [DCACHE_SET_ASSOC-1:0]     rd_vld_bits_i;
    logic [DCACHE_SET_ASSOC-1:0]     rd_hit_oh_i;
  } trace_wt_dcache_ctrl_structsi_t;
  typedef struct packed {
   logic                            miss_we_o;       
   logic [63:0]                     miss_wdata_o;    
   logic [DCACHE_SET_ASSOC-1:0]     miss_vld_bits_o; 
   logic [riscv::PLEN-1:0]          miss_paddr_o;
   logic                            miss_nc_o;       
   logic [2:0]                      miss_size_o;     
   logic [CACHE_ID_WIDTH-1:0]       miss_id_o;       
   logic [DCACHE_TAG_WIDTH-1:0]     rd_tag_o;        
   logic [DCACHE_CL_IDX_WIDTH-1:0]  rd_idx_o;
   logic [DCACHE_OFFSET_WIDTH-1:0]  rd_off_o;
   logic                            rd_req_o;        
   logic                            rd_tag_only_o;   
  } trace_wt_dcache_ctrl_structso_t;

  typedef struct packed {
    logic  [NumPorts-1:0][DCACHE_TAG_WIDTH-1:0]        rd_tag_i;           
    logic  [NumPorts-1:0][DCACHE_CL_IDX_WIDTH-1:0]     rd_idx_i;
    logic  [NumPorts-1:0][DCACHE_OFFSET_WIDTH-1:0]     rd_off_i;
    logic  [NumPorts-1:0]                              rd_req_i;           
    logic  [NumPorts-1:0]                              rd_tag_only_i;      
    logic  [NumPorts-1:0]                              rd_prio_i;          
    logic                                              wr_cl_vld_i;
    logic                                              wr_cl_nc_i;         
    logic                [DCACHE_SET_ASSOC-1:0]        wr_cl_we_i;         
    logic                [DCACHE_TAG_WIDTH-1:0]        wr_cl_tag_i;
    logic                [DCACHE_CL_IDX_WIDTH-1:0]     wr_cl_idx_i;
    logic                [DCACHE_OFFSET_WIDTH-1:0]     wr_cl_off_i;
    logic                [DCACHE_LINE_WIDTH-1:0]       wr_cl_data_i;
    logic                [DCACHE_LINE_WIDTH/8-1:0]     wr_cl_data_be_i;
    logic                [DCACHE_SET_ASSOC-1:0]        wr_vld_bits_i;
    logic                [DCACHE_SET_ASSOC-1:0]        wr_req_i;           
    logic                [DCACHE_CL_IDX_WIDTH-1:0]     wr_idx_i;
    logic                [DCACHE_OFFSET_WIDTH-1:0]     wr_off_i;
    logic                [63:0]                        wr_data_i;
    logic                [7:0]                         wr_data_be_i;
    wbuffer_t             [DCACHE_WBUF_DEPTH-1:0]      wbuffer_data_i;
  } trace_wt_dcache_mem_structsi_t;
  typedef struct packed {
    logic  [NumPorts-1:0]                              rd_ack_o;
    logic                [DCACHE_SET_ASSOC-1:0]        rd_vld_bits_o;
    logic                [DCACHE_SET_ASSOC-1:0]        rd_hit_oh_o;
    logic                [63:0]                        rd_data_o;
    logic                                              wr_ack_o;
  } trace_wt_dcache_mem_structso_t;

  typedef struct packed {
    logic                               cache_en_i;     
    dcache_req_i_t                      req_port_i;
    logic                               miss_ack_i;
    logic                               miss_rtrn_vld_i;
    logic [CACHE_ID_WIDTH-1:0]          miss_rtrn_id_i;  
    logic                               rd_ack_i;
    logic  [63:0]                       rd_data_i;       
    logic  [DCACHE_SET_ASSOC-1:0]       rd_vld_bits_i;   
    logic  [DCACHE_SET_ASSOC-1:0]       rd_hit_oh_i;
    logic                               wr_cl_vld_i;
    logic [DCACHE_CL_IDX_WIDTH-1:0]     wr_cl_idx_i;
    logic                               wr_ack_i;
  } trace_wt_dcache_wbuffer_structsi_t;
  typedef struct packed {
    logic                               empty_o;        
    dcache_req_o_t                      req_port_o;
    logic [riscv::PLEN-1:0]             miss_paddr_o;
    logic                               miss_req_o;
    logic                               miss_we_o;       
    logic [63:0]                        miss_wdata_o;
    logic [DCACHE_SET_ASSOC-1:0]        miss_vld_bits_o; 
    logic                               miss_nc_o;       
    logic [2:0]                         miss_size_o;     
    logic [CACHE_ID_WIDTH-1:0]          miss_id_o;       
    logic [DCACHE_TAG_WIDTH-1:0]        rd_tag_o;        
    logic [DCACHE_CL_IDX_WIDTH-1:0]     rd_idx_o;
    logic [DCACHE_OFFSET_WIDTH-1:0]     rd_off_o;
    logic                               rd_req_o;        
    logic                               rd_tag_only_o;   
    logic [DCACHE_SET_ASSOC-1:0]        wr_req_o;
    logic [DCACHE_CL_IDX_WIDTH-1:0]     wr_idx_o;
    logic [DCACHE_OFFSET_WIDTH-1:0]     wr_off_o;
    logic [63:0]                        wr_data_o;
    logic [7:0]                         wr_data_be_o;
    wbuffer_t  [DCACHE_WBUF_DEPTH-1:0]  wbuffer_data_o;
    logic [DCACHE_MAX_TX-1:0][riscv::PLEN-1:0]     tx_paddr_o;      
    logic [DCACHE_MAX_TX-1:0]           tx_vld_o;
  } trace_wt_dcache_wbuffer_structso_t;

  typedef struct packed {
      fu_data_t                 fu_data_i;
  } trace_alu_structsi_t;
  typedef struct packed {
     logic [63:0]              result_o;
     logic                     alu_branch_res_o;
  } trace_alu_structso_t;

  typedef struct packed {
      logic                          clk_i;
      logic                          rst_ni;
      logic                          flush_i;
      logic                          debug_req_i;
      ariane_pkg::fetch_entry_t      fetch_entry_i;
      logic                          fetch_entry_valid_i;
      logic                          issue_instr_ack_i;   
      riscv::priv_lvl_t              priv_lvl_i;          
      riscv::xs_t                    fs_i;                
      logic [2:0]                    frm_i;               
      logic [1:0]                    irq_i;
      ariane_pkg::irq_ctrl_t         irq_ctrl_i;
      logic                          debug_mode_i;        
      logic                          tvm_i;
      logic                          tw_i;
      logic                          tsr_i;
      ariane_pkg::scoreboard_entry_t decoded_instruction;
  } trace_id_stage_structsi_t;
  typedef struct packed {
     logic                          fetch_entry_ready_o; 
     ariane_pkg::scoreboard_entry_t issue_entry_o;       
     logic                          issue_entry_valid_o; 
     logic                          is_ctrl_flow_o;      
  } trace_id_stage_structso_t;

  localparam NrHarts = 1;
  localparam BusWidth = 64;
  typedef struct packed {
      logic                              testmode_i;
      logic                              dmi_rst_ni;      
      logic                              dmi_req_valid_i;
      dm::dmi_req_t                      dmi_req_i;
      logic                              dmi_resp_ready_i;
      hartinfo_t [NrHarts-1:0]           hartinfo_i;      
      logic [NrHarts-1:0]                halted_i;        
      logic [NrHarts-1:0]                unavailable_i;   
      logic [NrHarts-1:0]                resumeack_i;     
      logic                              cmderror_valid_i;  
      dm::cmderr_e                       cmderror_i;        
      logic                              cmdbusy_i;         
      logic [dm::DataCount-1:0][31:0]    data_i;
      logic                              data_valid_i;
      logic [BusWidth-1:0]               sbaddress_i;
      logic [BusWidth-1:0]               sbdata_i;
      logic                              sbdata_valid_i;
      logic                              sbbusy_i;
      logic                              sberror_valid_i; 
      logic [2:0]                        sberror_i; 
  } trace_dm_csrs_structsi_t;
  typedef struct packed {
     logic                              dmi_req_ready_o;
     logic                              dmi_resp_valid_o;
     dm::dmi_resp_t                     dmi_resp_o;
     logic                              ndmreset_o;      
     logic                              dmactive_o;      
     logic [19:0]                       hartsel_o;       
     logic [NrHarts-1:0]                haltreq_o;       
     logic [NrHarts-1:0]                resumereq_o;     
     logic                              clear_resumeack_o;
     logic                              cmd_valid_o;       
     dm::command_t                      cmd_o;             
     logic [dm::ProgBufSize-1:0][31:0]  progbuf_o; 
     logic [dm::DataCount-1:0][31:0]    data_o;
     logic [BusWidth-1:0]               sbaddress_o;
     logic                              sbaddress_write_valid_o;
     logic                              sbreadonaddr_o;
     logic                              sbautoincrement_o;
     logic [2:0]                        sbaccess_o;
     logic                              sbreadondata_o;
     logic [BusWidth-1:0]               sbdata_o;
     logic                              sbdata_read_valid_o;
     logic                              sbdata_write_valid_o;
  } trace_dm_csrs_structso_t;

  typedef struct packed {
      logic [19:0]                      hartsel_i;
      logic [NrHarts-1:0]               haltreq_i;
      logic [NrHarts-1:0]               resumereq_i;
      logic                             clear_resumeack_i;
      logic [dm::ProgBufSize-1:0][31:0] progbuf_i;    
      logic [dm::DataCount-1:0][31:0]   data_i;       
      logic                             cmd_valid_i;
      dm::command_t                     cmd_i;
      logic                             req_i;
      logic                             we_i;
      logic [BusWidth-1:0]              addr_i;
      logic [BusWidth-1:0]              wdata_i;
      logic [BusWidth/8-1:0]            be_i;
  } trace_dm_mem_structsi_t;
  typedef struct packed {
     logic [NrHarts-1:0]               debug_req_o;
     logic [NrHarts-1:0]               halted_o;    
     logic [NrHarts-1:0]               resuming_o;  
     logic [dm::DataCount-1:0][31:0]   data_o;       
     logic                             data_valid_o; 
     logic                             cmderror_valid_o;
     dm::cmderr_e                      cmderror_o;
     logic                             cmdbusy_o;
     logic [BusWidth-1:0]              rdata_o;
  } trace_dm_mem_structso_t;

  localparam DATA_WIDTH = 64;
  localparam NUM_WORDS  = 2**25;
  typedef struct packed {
     logic                          req_i;
     logic                          we_i;
     logic [$clog2(NUM_WORDS)-1:0]  addr_i;
     logic [DATA_WIDTH-1:0]         wdata_i;
     logic [(DATA_WIDTH+7)/8-1:0]   be_i;
  } trace_sram_structsi_t;
  typedef struct packed {
    logic [DATA_WIDTH-1:0]         rdata_o;
  } trace_sram_structso_t;

// ptw structure
  typedef struct packed {
     logic                    flush_i;
     logic                    ptw_active_o;
     logic                    walking_instr_o;
     logic                    ptw_error_o;
     logic                    enable_translation_i;
     logic                    en_ld_st_translation_i;
     logic                    lsu_is_store_i;
     dcache_req_o_t           req_port_i;
     dcache_req_i_t           req_port_o;
     tlb_update_t             itlb_update_o;
     tlb_update_t             dtlb_update_o;
     logic [riscv::VLEN-1:0]  update_vaddr_o;
     logic [ASID_WIDTH-1:0]   asid_i;
     logic                    itlb_access_i;
     logic                    itlb_hit_i;
     logic [riscv::VLEN-1:0]  itlb_vaddr_i;
     logic                    dtlb_access_i;
     logic                    dtlb_hit_i;
     logic [riscv::VLEN-1:0]  dtlb_vaddr_i;
     logic [riscv::PPNW-1:0]  satp_ppn_i;
     logic                    mxr_i;
     logic                    itlb_miss_o;
     logic                    dtlb_miss_o;
  } trace_ptw_structs_t;
  trace_ptw_structs_t ptw_struct, ptw_struct_previous;
  assign ptw_struct = {
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.flush_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.ptw_active_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.walking_instr_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.ptw_error_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.enable_translation_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.en_ld_st_translation_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.lsu_is_store_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.req_port_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.itlb_update_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.dtlb_update_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.update_vaddr_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.asid_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.itlb_access_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.itlb_hit_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.itlb_vaddr_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.dtlb_access_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.dtlb_hit_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.dtlb_vaddr_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.satp_ppn_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.mxr_i,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.itlb_miss_o,
     i_ariane.ex_stage_i.lsu_i.i_mmu.i_ptw.dtlb_miss_o
  };

// signal structure
  typedef struct packed {
    logic [31:0][63:0]     mem;
  } trace_signal_structs_t;
  trace_signal_structs_t signal_struct, signal_struct_previous;
  assign signal_struct = {
     i_ariane.issue_stage_i.i_issue_read_operands.i_ariane_regfile.mem
  };

// scoreboard structure
  typedef struct packed {
        logic                                                  flush_unissued_instr_i;
        logic                                                  flush_i;
        logic                                                  unresolved_branch_i;
        logic [ariane_pkg::REG_ADDR_SIZE-1:0]                  rs1_i;
        logic [ariane_pkg::REG_ADDR_SIZE-1:0]                  rs2_i;
        logic [ariane_pkg::REG_ADDR_SIZE-1:0]                  rs3_i;
        logic              [NR_COMMIT_PORTS-1:0]               commit_ack_i;
        ariane_pkg::scoreboard_entry_t                         decoded_instr_i;
        logic                                                  decoded_instr_valid_i;
        logic                                                  issue_ack_i;
        ariane_pkg::bp_resolve_t                               resolved_branch_i;
        logic [NR_WB_PORTS-1:0][ariane_pkg::TRANS_ID_BITS-1:0] trans_id_i;
        logic [NR_WB_PORTS-1:0][riscv::XLEN-1:0]               wbdata_i;
        ariane_pkg::exception_t [NR_WB_PORTS-1:0]              ex_i;
        logic [NR_WB_PORTS-1:0]                                wt_valid_i;
        logic                                                  sb_full_o;
        ariane_pkg::fu_t [2**ariane_pkg::REG_ADDR_SIZE-1:0]    rd_clobber_gpr_o;
        ariane_pkg::fu_t [2**ariane_pkg::REG_ADDR_SIZE-1:0]    rd_clobber_fpr_o;
        logic [riscv::XLEN-1:0]                                rs1_o;
        logic                                                  rs1_valid_o;
        logic [riscv::XLEN-1:0]                                rs2_o;
        logic                                                  rs2_valid_o;
        logic [ariane_pkg::FLEN-1:0]                           rs3_o;
        logic                                                  rs3_valid_o;
        ariane_pkg::scoreboard_entry_t [NR_COMMIT_PORTS-1:0]   commit_instr_o;
        logic                                                  decoded_instr_ack_o;
        ariane_pkg::scoreboard_entry_t                         issue_instr_o;
        logic                                                  issue_instr_valid_o;
  } trace_scoreboard_structs_t;
  trace_scoreboard_structs_t scoreboard_struct, scoreboard_struct_previous;
  assign scoreboard_struct = {
        i_ariane.issue_stage_i.i_scoreboard.flush_unissued_instr_i,
        i_ariane.issue_stage_i.i_scoreboard.flush_i,
        i_ariane.issue_stage_i.i_scoreboard.unresolved_branch_i,
        i_ariane.issue_stage_i.i_scoreboard.rs1_i,
        i_ariane.issue_stage_i.i_scoreboard.rs2_i,
        i_ariane.issue_stage_i.i_scoreboard.rs3_i,
        i_ariane.issue_stage_i.i_scoreboard.commit_ack_i,
        i_ariane.issue_stage_i.i_scoreboard.decoded_instr_i,
        i_ariane.issue_stage_i.i_scoreboard.decoded_instr_valid_i,
        i_ariane.issue_stage_i.i_scoreboard.issue_ack_i,
        i_ariane.issue_stage_i.i_scoreboard.resolved_branch_i,
        i_ariane.issue_stage_i.i_scoreboard.trans_id_i,
        i_ariane.issue_stage_i.i_scoreboard.wbdata_i,
        i_ariane.issue_stage_i.i_scoreboard.ex_i,
        i_ariane.issue_stage_i.i_scoreboard.wt_valid_i,
        i_ariane.issue_stage_i.i_scoreboard.sb_full_o,
        i_ariane.issue_stage_i.i_scoreboard.rd_clobber_gpr_o,
        i_ariane.issue_stage_i.i_scoreboard.rd_clobber_fpr_o,
        i_ariane.issue_stage_i.i_scoreboard.rs1_o,
        i_ariane.issue_stage_i.i_scoreboard.rs1_valid_o,
        i_ariane.issue_stage_i.i_scoreboard.rs2_o,
        i_ariane.issue_stage_i.i_scoreboard.rs2_valid_o,
        i_ariane.issue_stage_i.i_scoreboard.rs3_o,
        i_ariane.issue_stage_i.i_scoreboard.rs3_valid_o,
        i_ariane.issue_stage_i.i_scoreboard.commit_instr_o,
        i_ariane.issue_stage_i.i_scoreboard.decoded_instr_ack_o,
        i_ariane.issue_stage_i.i_scoreboard.issue_instr_o,
        i_ariane.issue_stage_i.i_scoreboard.issue_instr_valid_o
  };

// decoder structure
  typedef struct packed {
     logic               debug_req_i;
     logic [riscv::VLEN-1:0] pc_i;
     logic               is_compressed_i;
     logic [15:0]        compressed_instr_i;
     logic               is_illegal_i;
     logic [31:0]        instruction_i;
     branchpredict_sbe_t branch_predict_i;
     exception_t         ex_i;
     logic [1:0]         irq_i;
     irq_ctrl_t          irq_ctrl_i;
     riscv::priv_lvl_t   priv_lvl_i;
     logic               debug_mode_i;
     riscv::xs_t         fs_i;
     logic [2:0]         frm_i;
     logic               tvm_i;
     logic               tw_i;
     logic               tsr_i;
     scoreboard_entry_t  instruction_o;
     logic               is_control_flow_instr_o;
  } trace_decoder_structs_t;
  trace_decoder_structs_t decoder_struct, decoder_struct_previous;
  assign decoder_struct = {
     i_ariane.id_stage_i.decoder_i.debug_req_i,
     i_ariane.id_stage_i.decoder_i.pc_i,
     i_ariane.id_stage_i.decoder_i.is_compressed_i,
     i_ariane.id_stage_i.decoder_i.compressed_instr_i,
     i_ariane.id_stage_i.decoder_i.is_illegal_i,
     i_ariane.id_stage_i.decoder_i.instruction_i,
     i_ariane.id_stage_i.decoder_i.branch_predict_i,
     i_ariane.id_stage_i.decoder_i.ex_i,
     i_ariane.id_stage_i.decoder_i.irq_i,
     i_ariane.id_stage_i.decoder_i.irq_ctrl_i,
     i_ariane.id_stage_i.decoder_i.priv_lvl_i,
     i_ariane.id_stage_i.decoder_i.debug_mode_i,
     i_ariane.id_stage_i.decoder_i.fs_i,
     i_ariane.id_stage_i.decoder_i.frm_i,
     i_ariane.id_stage_i.decoder_i.tvm_i,
     i_ariane.id_stage_i.decoder_i.tw_i,
     i_ariane.id_stage_i.decoder_i.tsr_i,
     i_ariane.id_stage_i.decoder_i.instruction_o,
     i_ariane.id_stage_i.decoder_i.is_control_flow_instr_o
  };

  trace_ariane_structsi_t ariane_structi, ariane_structi_previous;
  trace_ariane_structso_t ariane_structo, ariane_structo_previous;

  trace_branch_structsi_t branch_structi, branch_structi_previous;
  trace_branch_structso_t branch_structo, branch_structo_previous;

  trace_commit_structsi_t commit_structi, commit_structi_previous;
  trace_commit_structso_t commit_structo, commit_structo_previous;

  trace_controller_structsi_t controller_structi, controller_structi_previous;

  trace_csr_regfile_structsi_t csr_regfile_structi, csr_regfile_structi_previous;
  trace_csr_regfile_structso_t csr_regfile_structo, csr_regfile_structo_previous;

  trace_issue_read_operands_structsi_t issue_read_operands_structi, issue_read_operands_structi_previous;
  trace_issue_read_operands_structso_t issue_read_operands_structo, issue_read_operands_structo_previous;

  trace_issue_stage_structsi_t issue_stage_structi, issue_stage_structi_previous;
  trace_issue_stage_structso_t issue_stage_structo, issue_stage_structo_previous;

  trace_load_store_structsi_t load_store_structi, load_store_structi_previous;
  trace_load_store_structso_t load_store_structo, load_store_structo_previous;

  trace_lsu_bypass_structsi_t lsu_bypass_structi, lsu_bypass_structi_previous;
  trace_lsu_bypass_structso_t lsu_bypass_structo, lsu_bypass_structo_previous;

  trace_mmu_structsi_t mmu_structi, mmu_structi_previous;
  trace_mmu_structso_t mmu_structo, mmu_structo_previous;

  trace_store_structsi_t store_structi, store_structi_previous;
  trace_store_structso_t store_structo, store_structo_previous;

  trace_frontend_structsi_t frontend_structi, frontend_structi_previous;
  trace_frontend_structso_t frontend_structo, frontend_structo_previous;

  trace_wt_cache_structsi_t wt_cache_structi, wt_cache_structi_previous;
  trace_wt_cache_structso_t wt_cache_structo, wt_cache_structo_previous;

  trace_wt_icache_structsi_t wt_icache_structi, wt_icache_structi_previous;
  trace_wt_icache_structso_t wt_icache_structo, wt_icache_structo_previous;

  trace_wt_dcache_missunit_structsi_t wt_dcache_missunit_structi, wt_dcache_missunit_structi_previous;
  trace_wt_dcache_missunit_structso_t wt_dcache_missunit_structo, wt_dcache_missunit_structo_previous;

  trace_wt_axi_adapter_structsi_t wt_axi_adapter_structi, wt_axi_adapter_structi_previous;
  trace_wt_axi_adapter_structso_t wt_axi_adapter_structo, wt_axi_adapter_structo_previous;

  trace_wt_dcache_ctrl_structsi_t wt_dcache_ctrl_structi, wt_dcache_ctrl_structi_previous;
  trace_wt_dcache_ctrl_structso_t wt_dcache_ctrl_structo, wt_dcache_ctrl_structo_previous;

  trace_wt_dcache_mem_structsi_t wt_dcache_mem_structi, wt_dcache_mem_structi_previous;
  trace_wt_dcache_mem_structso_t wt_dcache_mem_structo, wt_dcache_mem_structo_previous;

  trace_wt_dcache_wbuffer_structsi_t wt_dcache_wbuffer_structi, wt_dcache_wbuffer_structi_previous;
  trace_wt_dcache_wbuffer_structso_t wt_dcache_wbuffer_structo, wt_dcache_wbuffer_structo_previous;

  trace_alu_structsi_t alu_structi, alu_structi_previous;
  trace_alu_structso_t alu_structo, alu_structo_previous;

  trace_id_stage_structsi_t id_stage_structi, id_stage_structi_previous;
  trace_id_stage_structso_t id_stage_structo, id_stage_structo_previous;

  trace_dm_csrs_structsi_t dm_csrs_structi, dm_csrs_structi_previous;
  trace_dm_csrs_structso_t dm_csrs_structo, dm_csrs_structo_previous;

  trace_dm_mem_structsi_t dm_mem_structi, dm_mem_structi_previous;
  trace_dm_mem_structso_t dm_mem_structo, dm_mem_structo_previous;

  trace_sram_structsi_t sram_structi, sram_structi_previous;
  trace_sram_structso_t sram_structo, sram_structo_previous;


  assign ariane_structi = {
                    i_ariane.irq_i,
                    i_ariane.ipi_i,
                    i_ariane.time_irq_i,
                    i_ariane.debug_req_i,
                    i_ariane.axi_resp_i};
  assign ariane_structo = {
                    i_ariane.axi_req_o};

  assign branch_structi = {i_ariane.ex_stage_i.branch_unit_i.debug_mode_i,
                    i_ariane.ex_stage_i.branch_unit_i.fu_data_i,
                    i_ariane.ex_stage_i.branch_unit_i.pc_i,
                    i_ariane.ex_stage_i.branch_unit_i.is_compressed_instr_i,
                    i_ariane.ex_stage_i.branch_unit_i.fu_valid_i,
                    i_ariane.ex_stage_i.branch_unit_i.branch_valid_i,
                    i_ariane.ex_stage_i.branch_unit_i.branch_comp_res_i,
                    i_ariane.ex_stage_i.branch_unit_i.branch_predict_i};
  assign branch_structo = {i_ariane.ex_stage_i.branch_unit_i.branch_result_o,
                    i_ariane.ex_stage_i.branch_unit_i.resolved_branch_o,
                    i_ariane.ex_stage_i.branch_unit_i.resolve_branch_o,
                    i_ariane.ex_stage_i.branch_unit_i.branch_exception_o};

  assign commit_structi = {i_ariane.commit_stage_i.halt_i,
                           i_ariane.commit_stage_i.flush_dcache_i,
                           i_ariane.commit_stage_i.single_step_i,
                           i_ariane.commit_stage_i.commit_instr_i,
                           i_ariane.commit_stage_i.amo_resp_i,
                           i_ariane.commit_stage_i.csr_rdata_i,
                           i_ariane.commit_stage_i.csr_exception_i,
                           i_ariane.commit_stage_i.commit_lsu_ready_i,
                           i_ariane.commit_stage_i.no_st_pending_i};
  assign commit_structo = {i_ariane.commit_stage_i.exception_o,
                           i_ariane.commit_stage_i.dirty_fp_state_o,
                           i_ariane.commit_stage_i.commit_ack_o,
                           i_ariane.commit_stage_i.waddr_o,
                           i_ariane.commit_stage_i.wdata_o,
                           i_ariane.commit_stage_i.we_gpr_o,
                           i_ariane.commit_stage_i.we_fpr_o,
                           i_ariane.commit_stage_i.pc_o,
                           i_ariane.commit_stage_i.csr_op_o,
                           i_ariane.commit_stage_i.csr_wdata_o,
                           i_ariane.commit_stage_i.csr_write_fflags_o,
                           i_ariane.commit_stage_i.commit_lsu_o,
                           i_ariane.commit_stage_i.amo_valid_commit_o,
                           i_ariane.commit_stage_i.commit_csr_o,
                           i_ariane.commit_stage_i.fence_i_o,
                           i_ariane.commit_stage_i.fence_o,
                           i_ariane.commit_stage_i.flush_commit_o,
                           i_ariane.commit_stage_i.sfence_vma_o};

  assign controller_structi = {i_ariane.controller_i.flush_dcache_ack_i,
                               i_ariane.controller_i.halt_csr_i,
                               i_ariane.controller_i.eret_i,
                               i_ariane.controller_i.ex_valid_i,
                               i_ariane.controller_i.set_debug_pc_i,
                               i_ariane.controller_i.resolved_branch_i,
                               i_ariane.controller_i.flush_csr_i,
                               i_ariane.controller_i.fence_i_i,
                               i_ariane.controller_i.fence_i,
                               i_ariane.controller_i.sfence_vma_i,
                               i_ariane.controller_i.flush_commit_i,
                               i_ariane.controller_i.flush_unissued_instr_o};

  assign csr_regfile_structi = {i_ariane.csr_regfile_i.time_irq_i,
                                i_ariane.csr_regfile_i.commit_instr_i,
                                i_ariane.csr_regfile_i.commit_ack_i,
                                i_ariane.csr_regfile_i.boot_addr_i,
                                i_ariane.csr_regfile_i.hart_id_i,
                                i_ariane.csr_regfile_i.ex_i,
                                i_ariane.csr_regfile_i.csr_op_i,
                                i_ariane.csr_regfile_i.csr_addr_i,
                                i_ariane.csr_regfile_i.csr_wdata_i,
                                i_ariane.csr_regfile_i.dirty_fp_state_i,
                                i_ariane.csr_regfile_i.csr_write_fflags_i,
                                i_ariane.csr_regfile_i.pc_i,
                                i_ariane.csr_regfile_i.irq_i,
                                i_ariane.csr_regfile_i.ipi_i,
                                i_ariane.csr_regfile_i.debug_req_i,
                                i_ariane.csr_regfile_i.perf_data_i};
  assign csr_regfile_structo = {i_ariane.csr_regfile_i.flush_o,
                                i_ariane.csr_regfile_i.halt_csr_o,
                                i_ariane.csr_regfile_i.csr_rdata_o,
                                i_ariane.csr_regfile_i.csr_exception_o,
                                i_ariane.csr_regfile_i.epc_o,
                                i_ariane.csr_regfile_i.eret_o,
                                i_ariane.csr_regfile_i.trap_vector_base_o,
                                i_ariane.csr_regfile_i.priv_lvl_o,
                                i_ariane.csr_regfile_i.fs_o,
                                i_ariane.csr_regfile_i.fflags_o,
                                i_ariane.csr_regfile_i.frm_o,
                                i_ariane.csr_regfile_i.fprec_o,
                                i_ariane.csr_regfile_i.irq_ctrl_o,
                                i_ariane.csr_regfile_i.en_translation_o,
                                i_ariane.csr_regfile_i.en_ld_st_translation_o,
                                i_ariane.csr_regfile_i.ld_st_priv_lvl_o,
                                i_ariane.csr_regfile_i.sum_o,
                                i_ariane.csr_regfile_i.mxr_o,
                                i_ariane.csr_regfile_i.satp_ppn_o,
                                i_ariane.csr_regfile_i.asid_o,
                                i_ariane.csr_regfile_i.set_debug_pc_o,
                                i_ariane.csr_regfile_i.tvm_o,
                                i_ariane.csr_regfile_i.tw_o,
                                i_ariane.csr_regfile_i.tsr_o,
                                i_ariane.csr_regfile_i.debug_mode_o,
                                i_ariane.csr_regfile_i.single_step_o,
                                i_ariane.csr_regfile_i.icache_en_o,
                                i_ariane.csr_regfile_i.dcache_en_o,
                                i_ariane.csr_regfile_i.perf_addr_o,
                                i_ariane.csr_regfile_i.perf_data_o,
                                i_ariane.csr_regfile_i.perf_we_o};

  assign issue_read_operands_structi = {i_ariane.issue_stage_i.i_issue_read_operands.flush_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.issue_instr_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.issue_instr_valid_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs1_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs1_valid_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs2_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs2_valid_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs3_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs3_valid_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rd_clobber_gpr_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rd_clobber_fpr_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.flu_ready_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.lsu_ready_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.fpu_ready_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.waddr_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.wdata_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.we_gpr_i,
                                        i_ariane.issue_stage_i.i_issue_read_operands.we_fpr_i};
  assign issue_read_operands_structo = {i_ariane.issue_stage_i.i_issue_read_operands.issue_ack_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs1_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs2_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.rs3_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.fu_data_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.pc_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.is_compressed_instr_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.alu_valid_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.branch_valid_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.branch_predict_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.lsu_valid_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.mult_valid_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.fpu_valid_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.fpu_fmt_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.fpu_rm_o,
                                        i_ariane.issue_stage_i.i_issue_read_operands.csr_valid_o};

  assign issue_stage_structi = {i_ariane.issue_stage_i.flush_unissued_instr_i,
                                i_ariane.issue_stage_i.flush_i,
                                i_ariane.issue_stage_i.decoded_instr_i,
                                i_ariane.issue_stage_i.decoded_instr_valid_i,
                                i_ariane.issue_stage_i.is_ctrl_flow_i,
                                i_ariane.issue_stage_i.flu_ready_i,
                                i_ariane.issue_stage_i.resolve_branch_i,
                                i_ariane.issue_stage_i.lsu_ready_i,
                                i_ariane.issue_stage_i.fpu_ready_i,
                                i_ariane.issue_stage_i.trans_id_i,
                                i_ariane.issue_stage_i.resolved_branch_i,
                                i_ariane.issue_stage_i.wbdata_i,
                                i_ariane.issue_stage_i.ex_ex_i,
                                i_ariane.issue_stage_i.wt_valid_i,
                                i_ariane.issue_stage_i.waddr_i,
                                i_ariane.issue_stage_i.wdata_i,
                                i_ariane.issue_stage_i.we_gpr_i,
                                i_ariane.issue_stage_i.we_fpr_i,
                                i_ariane.issue_stage_i.commit_ack_i};
  assign issue_stage_structo = {i_ariane.issue_stage_i.sb_full_o,
                                i_ariane.issue_stage_i.decoded_instr_ack_o,
                                i_ariane.issue_stage_i.fu_data_o,
                                i_ariane.issue_stage_i.pc_o,
                                i_ariane.issue_stage_i.is_compressed_instr_o,
                                i_ariane.issue_stage_i.alu_valid_o,
                                i_ariane.issue_stage_i.lsu_valid_o,
                                i_ariane.issue_stage_i.branch_valid_o,
                                i_ariane.issue_stage_i.branch_predict_o,
                                i_ariane.issue_stage_i.mult_valid_o,
                                i_ariane.issue_stage_i.fpu_valid_o,
                                i_ariane.issue_stage_i.fpu_fmt_o,
                                i_ariane.issue_stage_i.fpu_rm_o,
                                i_ariane.issue_stage_i.csr_valid_o,
                                i_ariane.issue_stage_i.commit_instr_o};

  assign load_store_structi = {i_ariane.ex_stage_i.lsu_i.flush_i,
                               i_ariane.ex_stage_i.lsu_i.amo_valid_commit_i,
                               i_ariane.ex_stage_i.lsu_i.fu_data_i,
                               i_ariane.ex_stage_i.lsu_i.lsu_valid_i,
                               i_ariane.ex_stage_i.lsu_i.commit_i,
                               i_ariane.ex_stage_i.lsu_i.enable_translation_i,
                               i_ariane.ex_stage_i.lsu_i.en_ld_st_translation_i,
                               i_ariane.ex_stage_i.lsu_i.icache_areq_i,
                               i_ariane.ex_stage_i.lsu_i.priv_lvl_i,
                               i_ariane.ex_stage_i.lsu_i.ld_st_priv_lvl_i,
                               i_ariane.ex_stage_i.lsu_i.sum_i,
                               i_ariane.ex_stage_i.lsu_i.mxr_i,
                               i_ariane.ex_stage_i.lsu_i.satp_ppn_i,
                               i_ariane.ex_stage_i.lsu_i.asid_i,
                               i_ariane.ex_stage_i.lsu_i.flush_tlb_i,
                               i_ariane.ex_stage_i.lsu_i.dcache_req_ports_i,
                               i_ariane.ex_stage_i.lsu_i.amo_resp_i};
  assign load_store_structo = {i_ariane.ex_stage_i.lsu_i.no_st_pending_o,
                               i_ariane.ex_stage_i.lsu_i.lsu_ready_o,
                               i_ariane.ex_stage_i.lsu_i.load_trans_id_o,
                               i_ariane.ex_stage_i.lsu_i.load_result_o,
                               i_ariane.ex_stage_i.lsu_i.load_valid_o,
                               i_ariane.ex_stage_i.lsu_i.load_exception_o,
                               i_ariane.ex_stage_i.lsu_i.store_trans_id_o,
                               i_ariane.ex_stage_i.lsu_i.store_result_o,
                               i_ariane.ex_stage_i.lsu_i.store_valid_o,
                               i_ariane.ex_stage_i.lsu_i.store_exception_o,
                               i_ariane.ex_stage_i.lsu_i.commit_ready_o,
                               i_ariane.ex_stage_i.lsu_i.icache_areq_o,
                               i_ariane.ex_stage_i.lsu_i.itlb_miss_o,
                               i_ariane.ex_stage_i.lsu_i.dtlb_miss_o,
                               i_ariane.ex_stage_i.lsu_i.dcache_req_ports_o,
                               i_ariane.ex_stage_i.lsu_i.amo_req_o};

  assign lsu_bypass_structi = {i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.flush_i,
                               i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.lsu_req_i,
                               i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.lus_req_valid_i,
                               i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.pop_ld_i,
                               i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.pop_st_i};
  assign lsu_bypass_structo = {i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.lsu_ctrl_o,
                               i_ariane.ex_stage_i.lsu_i.lsu_bypass_i.ready_o};

  assign mmu_structi = {i_ariane.ex_stage_i.lsu_i.i_mmu.flush_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.enable_translation_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.en_ld_st_translation_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.icache_areq_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.misaligned_ex_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_req_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_vaddr_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_is_store_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.priv_lvl_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.ld_st_priv_lvl_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.sum_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.mxr_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.satp_ppn_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.asid_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.flush_tlb_i,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.req_port_i};
  assign mmu_structo = {i_ariane.ex_stage_i.lsu_i.i_mmu.icache_areq_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_dtlb_hit_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_valid_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_paddr_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.lsu_exception_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.itlb_miss_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.dtlb_miss_o,
                        i_ariane.ex_stage_i.lsu_i.i_mmu.req_port_o};

  assign store_structi = {i_ariane.ex_stage_i.lsu_i.i_store_unit.flush_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.valid_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.lsu_ctrl_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.commit_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.amo_valid_commit_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.paddr_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.ex_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.dtlb_hit_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.page_offset_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.amo_resp_i,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.req_port_i};
  assign store_structo = {i_ariane.ex_stage_i.lsu_i.i_store_unit.no_st_pending_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.pop_st_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.commit_ready_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.valid_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.trans_id_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.result_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.ex_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.translation_req_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.vaddr_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.page_offset_matches_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.amo_req_o,
                          i_ariane.ex_stage_i.lsu_i.i_store_unit.req_port_o};

  assign frontend_structi = {i_ariane.i_frontend.flush_i,
                             i_ariane.i_frontend.flush_bp_i,
                             i_ariane.i_frontend.debug_mode_i,
                             i_ariane.i_frontend.boot_addr_i,
                             i_ariane.i_frontend.resolved_branch_i,
                             i_ariane.i_frontend.set_pc_commit_i,
                             i_ariane.i_frontend.pc_commit_i,
                             i_ariane.i_frontend.epc_i,
                             i_ariane.i_frontend.eret_i,
                             i_ariane.i_frontend.trap_vector_base_i,
                             i_ariane.i_frontend.ex_valid_i,
                             i_ariane.i_frontend.set_debug_pc_i,
                             i_ariane.i_frontend.icache_dreq_i,
                             i_ariane.i_frontend.fetch_entry_ready_i};
  assign frontend_structo = {i_ariane.i_frontend.icache_dreq_o,
                             i_ariane.i_frontend.fetch_entry_o,
                             i_ariane.i_frontend.fetch_entry_valid_o};

  assign wt_cache_structi = {i_ariane.i_cache_subsystem.icache_en_i,
                             i_ariane.i_cache_subsystem.dcache_flush_i,
                             i_ariane.i_cache_subsystem.icache_areq_i,
                             i_ariane.i_cache_subsystem.icache_dreq_i,
                             i_ariane.i_cache_subsystem.dcache_enable_i,
                             i_ariane.i_cache_subsystem.dcache_flush_i,
                             i_ariane.i_cache_subsystem.dcache_amo_req_i,
                             i_ariane.i_cache_subsystem.dcache_req_ports_i,
                             i_ariane.i_cache_subsystem.axi_resp_i};
  assign wt_cache_structo = {i_ariane.i_cache_subsystem.icache_miss_o,
                             i_ariane.i_cache_subsystem.icache_areq_o,
                             i_ariane.i_cache_subsystem.icache_dreq_o,
                             i_ariane.i_cache_subsystem.dcache_flush_ack_o,
                             i_ariane.i_cache_subsystem.dcache_miss_o,
                             i_ariane.i_cache_subsystem.dcache_amo_resp_o,
                             i_ariane.i_cache_subsystem.dcache_req_ports_o,
                             i_ariane.i_cache_subsystem.wbuffer_empty_o,
                             i_ariane.i_cache_subsystem.axi_req_o};

  assign wt_icache_structi = {i_ariane.i_cache_subsystem.i_wt_icache.flush_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.en_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.areq_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.dreq_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.mem_rtrn_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.mem_rtrn_i,
                              i_ariane.i_cache_subsystem.i_wt_icache.mem_data_ack_i};
  assign wt_icache_structo = {i_ariane.i_cache_subsystem.i_wt_icache.miss_o,
                              i_ariane.i_cache_subsystem.i_wt_icache.dreq_o,
                              i_ariane.i_cache_subsystem.i_wt_icache.mem_data_req_o,
                              i_ariane.i_cache_subsystem.i_wt_icache.mem_data_o};

  assign wt_dcache_missunit_structi = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.flush_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wbuffer_empty_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.amo_req_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_req_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_nc_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_we_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_wdata_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_paddr_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_vld_bits_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_size_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_id_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.tx_paddr_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.tx_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.mem_rtrn_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.mem_rtrn_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.mem_data_ack_i};
  assign wt_dcache_missunit_structo = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.flush_ack_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.cache_en_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.amo_resp_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_ack_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_replay_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_rtrn_vld_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.miss_rtrn_id_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_vld_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_nc_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_we_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_tag_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_idx_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_off_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_data_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_cl_data_be_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.wr_vld_bits_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.mem_data_req_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_missunit.mem_data_o};

  assign wt_axi_adapter_structi = {
                              i_ariane.i_cache_subsystem.i_adapter.icache_data_req_i,
                              i_ariane.i_cache_subsystem.i_adapter.icache_data_i,
                              i_ariane.i_cache_subsystem.i_adapter.dcache_data_req_i,
                              i_ariane.i_cache_subsystem.i_adapter.dcache_data_i,
                              i_ariane.i_cache_subsystem.i_adapter.axi_resp_i};
  assign wt_axi_adapter_structo = {
                              i_ariane.i_cache_subsystem.i_adapter.icache_data_ack_o,
                              i_ariane.i_cache_subsystem.i_adapter.icache_rtrn_vld_o,
                              i_ariane.i_cache_subsystem.i_adapter.icache_rtrn_o,
                              i_ariane.i_cache_subsystem.i_adapter.dcache_data_ack_o,
                              i_ariane.i_cache_subsystem.i_adapter.dcache_rtrn_vld_o,
                              i_ariane.i_cache_subsystem.i_adapter.dcache_rtrn_o,
                              i_ariane.i_cache_subsystem.i_adapter.axi_req_o};

  assign wt_dcache_ctrl_structi = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.cache_en_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.req_port_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_ack_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_replay_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_rtrn_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.wr_cl_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_ack_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_data_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_vld_bits_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_hit_oh_i};
  assign wt_dcache_ctrl_structo = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_we_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_wdata_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_vld_bits_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_paddr_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_nc_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_size_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.miss_id_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_tag_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_idx_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_off_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_req_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.gen_rd_ports[0].i_wt_dcache_ctrl.rd_tag_only_o};

  assign wt_dcache_mem_structi = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_tag_i,           
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_idx_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_off_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_req_i,           
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_tag_only_i,      
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_prio_i,          
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_vld_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_nc_i,         
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_we_i,         
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_tag_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_idx_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_off_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_data_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_cl_data_be_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_vld_bits_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_req_i,           
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_idx_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_off_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_data_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_data_be_i,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wbuffer_data_i};
  assign wt_dcache_mem_structo = {
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_ack_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_vld_bits_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_hit_oh_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.rd_data_o,
                              i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_mem.wr_ack_o};

  assign wt_dcache_wbuffer_structi = {
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.cache_en_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.req_port_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_ack_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_rtrn_vld_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_rtrn_id_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_ack_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_data_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_vld_bits_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_hit_oh_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_cl_vld_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_cl_idx_i,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_ack_i};
  assign wt_dcache_wbuffer_structo = {
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.empty_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.req_port_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_paddr_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_req_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_we_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_wdata_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_vld_bits_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_nc_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_size_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.miss_id_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_tag_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_idx_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_off_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_req_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.rd_tag_only_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_req_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_idx_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_off_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_data_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wr_data_be_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.wbuffer_data_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.tx_paddr_o,
    i_ariane.i_cache_subsystem.i_wt_dcache.i_wt_dcache_wbuffer.tx_vld_o};

  assign alu_structi = {
      i_ariane.ex_stage_i.alu_i.fu_data_i
  };
  assign alu_structo = {
     i_ariane.ex_stage_i.alu_i.result_o,
     i_ariane.ex_stage_i.alu_i.alu_branch_res_o
  };

  assign id_stage_structi = {
      i_ariane.id_stage_i.clk_i,
      i_ariane.id_stage_i.rst_ni,
      i_ariane.id_stage_i.flush_i,
      i_ariane.id_stage_i.debug_req_i,
      i_ariane.id_stage_i.fetch_entry_i,
      i_ariane.id_stage_i.fetch_entry_valid_i,
      i_ariane.id_stage_i.issue_instr_ack_i,   
      i_ariane.id_stage_i.priv_lvl_i,          
      i_ariane.id_stage_i.fs_i,                
      i_ariane.id_stage_i.frm_i,               
      i_ariane.id_stage_i.irq_i,
      i_ariane.id_stage_i.irq_ctrl_i,
      i_ariane.id_stage_i.debug_mode_i,        
      i_ariane.id_stage_i.tvm_i,
      i_ariane.id_stage_i.tw_i,
      i_ariane.id_stage_i.tsr_i,
      i_ariane.id_stage_i.decoded_instruction
  };
  assign id_stage_structo = {
     i_ariane.id_stage_i.fetch_entry_ready_o, 
     i_ariane.id_stage_i.issue_entry_o,       
     i_ariane.id_stage_i.issue_entry_valid_o, 
     i_ariane.id_stage_i.is_ctrl_flow_o       
  };

  assign dm_csrs_structi = {
      i_dm_top.i_dm_csrs.testmode_i,
      i_dm_top.i_dm_csrs.dmi_rst_ni,      
      i_dm_top.i_dm_csrs.dmi_req_valid_i,
      i_dm_top.i_dm_csrs.dmi_req_i,
      i_dm_top.i_dm_csrs.dmi_resp_ready_i,
      i_dm_top.i_dm_csrs.hartinfo_i,      
      i_dm_top.i_dm_csrs.halted_i,        
      i_dm_top.i_dm_csrs.unavailable_i,   
      i_dm_top.i_dm_csrs.resumeack_i,     
      i_dm_top.i_dm_csrs.cmderror_valid_i,  
      i_dm_top.i_dm_csrs.cmderror_i,        
      i_dm_top.i_dm_csrs.cmdbusy_i,         
      i_dm_top.i_dm_csrs.data_i,
      i_dm_top.i_dm_csrs.data_valid_i,
      i_dm_top.i_dm_csrs.sbaddress_i,
      i_dm_top.i_dm_csrs.sbdata_i,
      i_dm_top.i_dm_csrs.sbdata_valid_i,
      i_dm_top.i_dm_csrs.sbbusy_i,
      i_dm_top.i_dm_csrs.sberror_valid_i, 
      i_dm_top.i_dm_csrs.sberror_i 
  };
  assign dm_csrs_structo = {
     i_dm_top.i_dm_csrs.dmi_req_ready_o,
     i_dm_top.i_dm_csrs.dmi_resp_valid_o,
     i_dm_top.i_dm_csrs.dmi_resp_o,
     i_dm_top.i_dm_csrs.ndmreset_o,      
     i_dm_top.i_dm_csrs.dmactive_o,      
     i_dm_top.i_dm_csrs.hartsel_o,       
     i_dm_top.i_dm_csrs.haltreq_o,       
     i_dm_top.i_dm_csrs.resumereq_o,     
     i_dm_top.i_dm_csrs.clear_resumeack_o,
     i_dm_top.i_dm_csrs.cmd_valid_o,       
     i_dm_top.i_dm_csrs.cmd_o,             
     i_dm_top.i_dm_csrs.progbuf_o, 
     i_dm_top.i_dm_csrs.data_o,
     i_dm_top.i_dm_csrs.sbaddress_o,
     i_dm_top.i_dm_csrs.sbaddress_write_valid_o,
     i_dm_top.i_dm_csrs.sbreadonaddr_o,
     i_dm_top.i_dm_csrs.sbautoincrement_o,
     i_dm_top.i_dm_csrs.sbaccess_o,
     i_dm_top.i_dm_csrs.sbreadondata_o,
     i_dm_top.i_dm_csrs.sbdata_o,
     i_dm_top.i_dm_csrs.sbdata_read_valid_o,
     i_dm_top.i_dm_csrs.sbdata_write_valid_o
  };

  assign dm_mem_structi = {
      i_dm_top.i_dm_mem.hartsel_i,
      i_dm_top.i_dm_mem.haltreq_i,
      i_dm_top.i_dm_mem.resumereq_i,
      i_dm_top.i_dm_mem.clear_resumeack_i,
      i_dm_top.i_dm_mem.progbuf_i,    
      i_dm_top.i_dm_mem.data_i,       
      i_dm_top.i_dm_mem.cmd_valid_i,
      i_dm_top.i_dm_mem.cmd_i,
      i_dm_top.i_dm_mem.req_i,
      i_dm_top.i_dm_mem.we_i,
      i_dm_top.i_dm_mem.addr_i,
      i_dm_top.i_dm_mem.wdata_i,
      i_dm_top.i_dm_mem.be_i
  };
  assign dm_mem_structo = {
     i_dm_top.i_dm_mem.debug_req_o,
     i_dm_top.i_dm_mem.halted_o,    
     i_dm_top.i_dm_mem.resuming_o,  
     i_dm_top.i_dm_mem.data_o,       
     i_dm_top.i_dm_mem.data_valid_o, 
     i_dm_top.i_dm_mem.cmderror_valid_o,
     i_dm_top.i_dm_mem.cmderror_o,
     i_dm_top.i_dm_mem.cmdbusy_o,
     i_dm_top.i_dm_mem.rdata_o
  };

  assign sram_structi = {
     i_sram.req_i,
     i_sram.we_i,
     i_sram.addr_i,
     i_sram.wdata_i,
     i_sram.be_i
  };
  assign sram_structo = {
     i_sram.rdata_o
  };

  int ariane_file;
  string ariane_file_name = "debug_trace_structs_ariane.log";
  int branch_file;
  string branch_file_name = "debug_trace_structs_branch_unit.log";
  int commit_file;
  string commit_file_name = "debug_trace_structs_commit_stage.log";
  int controller_file;
  string controller_file_name = "debug_trace_structs_controller.log";
  int csr_regfile_file;
  string csr_regfile_file_name = "debug_trace_structs_csr_regfile.log";
  int issue_read_operands_file;
  string issue_read_operands_file_name = "debug_trace_structs_issue_read_operands.log";
  int issue_stage_file;
  string issue_stage_file_name = "debug_trace_structs_issue_stage.log";
  int load_store_file;
  string load_store_file_name = "debug_trace_structs_load_store_unit.log";
  int lsu_bypass_file;
  string lsu_bypass_file_name = "debug_trace_structs_lsu_bypass.log";
  int mmu_file;
  string mmu_file_name = "debug_trace_structs_mmu.log";
  int store_file;
  string store_file_name = "debug_trace_structs_store_unit.log";
  int frontend_file;
  string frontend_file_name = "debug_trace_structs_frontend_unit.log";
  int wt_cache_file;
  string wt_cache_file_name = "debug_trace_structs_wt_cache.log";
  int wt_icache_file;
  string wt_icache_file_name = "debug_trace_structs_wt_icache.log";
  int wt_dcache_missunit_file;
  string wt_dcache_missunit_file_name = "debug_trace_structs_wt_dcache_missunit.log";
  int wt_axi_adapter_file;
  string wt_axi_adapter_file_name = "debug_trace_structs_wt_axi_adapter.log";
  int wt_dcache_ctrl_file;
  string wt_dcache_ctrl_file_name = "debug_trace_structs_wt_dcache_ctrl.log";
  int wt_dcache_mem_file;
  string wt_dcache_mem_file_name = "debug_trace_structs_wt_dcache_mem.log";
  int wt_dcache_wbuffer_file;
  string wt_dcache_wbuffer_file_name = "debug_trace_structs_wt_dcache_wbuffer.log";
  int alu_file;
  string alu_file_name = "debug_trace_structs_alu.log";
  int id_stage_file;
  string id_stage_file_name = "debug_trace_structs_id_stage.log";
  int dm_csrs_file;
  string dm_csrs_file_name = "debug_trace_structs_dm_csrs.log";
  int dm_mem_file;
  string dm_mem_file_name = "debug_trace_structs_dm_mem.log";
  int sram_file;
  string sram_file_name = "debug_trace_structs_sram.log";
  int signal_file;
  string signal_file_name = "debug_trace_structs_signal.log";
  int ptw_file;
  string ptw_file_name = "debug_trace_structs_ptw.log";
  int scoreboard_file;
  string scoreboard_file_name = "debug_trace_structs_scoreboard.log";
  int decoder_file;
  string decoder_file_name = "debug_trace_structs_decoder.log";

  initial begin
    if (DEBUG_START != 64'h0 || DEBUG_STOP != 64'h0) begin
      ariane_file = $fopen(ariane_file_name, "w");
      $display("[TRACER] Output filename is: %s", ariane_file_name);
      branch_file = $fopen(branch_file_name, "w");
      $display("[TRACER] Output filename is: %s", branch_file_name);
      commit_file = $fopen(commit_file_name, "w");
      $display("[TRACER] Output filename is: %s", commit_file_name);
      controller_file = $fopen(controller_file_name, "w");
      $display("[TRACER] Output filename is: %s", controller_file_name);
      csr_regfile_file = $fopen(csr_regfile_file_name, "w");
      $display("[TRACER] Output filename is: %s", csr_regfile_file_name);
      issue_read_operands_file = $fopen(issue_read_operands_file_name, "w");
      $display("[TRACER] Output filename is: %s", issue_read_operands_file_name);
      issue_stage_file = $fopen(issue_stage_file_name, "w");
      $display("[TRACER] Output filename is: %s", issue_stage_file_name);
      load_store_file = $fopen(load_store_file_name, "w");
      $display("[TRACER] Output filename is: %s", load_store_file_name);
      lsu_bypass_file = $fopen(lsu_bypass_file_name, "w");
      $display("[TRACER] Output filename is: %s", lsu_bypass_file_name);
      mmu_file = $fopen(mmu_file_name, "w");
      $display("[TRACER] Output filename is: %s", mmu_file_name);
      store_file = $fopen(store_file_name, "w");
      $display("[TRACER] Output filename is: %s", store_file_name);
      frontend_file = $fopen(frontend_file_name, "w");
      $display("[TRACER] Output filename is: %s", frontend_file_name);
      wt_cache_file = $fopen(wt_cache_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_cache_file_name);
      wt_icache_file = $fopen(wt_icache_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_icache_file_name);
      wt_dcache_missunit_file = $fopen(wt_dcache_missunit_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_dcache_missunit_file_name);
      wt_axi_adapter_file = $fopen(wt_axi_adapter_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_axi_adapter_file_name);
      wt_dcache_ctrl_file = $fopen(wt_dcache_ctrl_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_dcache_ctrl_file_name);
      wt_dcache_mem_file = $fopen(wt_dcache_mem_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_dcache_mem_file_name);
      wt_dcache_wbuffer_file = $fopen(wt_dcache_wbuffer_file_name, "w");
      $display("[TRACER] Output filename is: %s", wt_dcache_wbuffer_file_name);
      alu_file = $fopen(alu_file_name, "w");
      $display("[TRACER] Output filename is: %s", alu_file_name);
      id_stage_file = $fopen(id_stage_file_name, "w");
      $display("[TRACER] Output filename is: %s", id_stage_file_name);
      dm_csrs_file = $fopen(dm_csrs_file_name, "w");
      $display("[TRACER] Output filename is: %s", dm_csrs_file_name);
      dm_mem_file = $fopen(dm_mem_file_name, "w");
      $display("[TRACER] Output filename is: %s", dm_mem_file_name);
      sram_file = $fopen(sram_file_name, "w");
      $display("[TRACER] Output filename is: %s", sram_file_name);
      signal_file = $fopen(signal_file_name, "w");
      $display("[TRACER] Output filename is: %s", signal_file_name);
      scoreboard_file = $fopen(scoreboard_file_name, "w");
      $display("[TRACER] Output filename is: %s", scoreboard_file_name);
      decoder_file = $fopen(decoder_file_name, "w");
      $display("[TRACER] Output filename is: %s", decoder_file_name);
    end
  end

  logic [31:0] cyclesToPrint;
  always_ff @(posedge i_ariane.clk_i or negedge i_ariane.rst_ni) begin
        if (cycles > DEBUG_START && cycles < DEBUG_STOP) begin
          cyclesToPrint=0;
          if (ariane_structi != ariane_structi_previous
              || ariane_structo != ariane_structo_previous)
            $fwriteh(ariane_file, "%d %p %p\n", cyclesToPrint, ariane_structi, ariane_structo);
          if (branch_structi != branch_structi_previous
              || branch_structo != branch_structo_previous)
            $fwriteh(branch_file, "%d %p %p\n", cyclesToPrint, branch_structi, branch_structo);
          if (commit_structi != commit_structi_previous
              || commit_structo != commit_structo_previous)
            $fwriteh(commit_file, "%d %p %p\n", cyclesToPrint, commit_structi, commit_structo);
          if (controller_structi != controller_structi_previous)
            $fwriteh(controller_file, "%d %p\n", cyclesToPrint, controller_structi);
          if (csr_regfile_structi != csr_regfile_structi_previous
              || csr_regfile_structo != csr_regfile_structo_previous)
            $fwriteh(csr_regfile_file, "%d %p %p\n", cyclesToPrint, csr_regfile_structi, csr_regfile_structo);
          if (issue_read_operands_structi != issue_read_operands_structi_previous
              || issue_read_operands_structo != issue_read_operands_structo_previous)
            $fwriteh(issue_read_operands_file, "%d %p %p\n", cyclesToPrint, issue_read_operands_structi, issue_read_operands_structo);
          if (issue_stage_structi != issue_stage_structi_previous
              || issue_stage_structo != issue_stage_structo_previous)
            $fwriteh(issue_stage_file, "%d %p %p\n", cyclesToPrint, issue_stage_structi, issue_stage_structo);
          if (load_store_structi != load_store_structi_previous
              || load_store_structo != load_store_structo_previous)
            $fwriteh(load_store_file, "%d %p %p\n", cyclesToPrint, load_store_structi, load_store_structo);
          if (lsu_bypass_structi != lsu_bypass_structi_previous
              || lsu_bypass_structo != lsu_bypass_structo_previous)
            $fwriteh(lsu_bypass_file, "%d %p %p\n", cyclesToPrint, lsu_bypass_structi, lsu_bypass_structo);
          if (mmu_structi != mmu_structi_previous
              || mmu_structo != mmu_structo_previous)
            $fwriteh(mmu_file, "%d %p %p\n", cyclesToPrint, mmu_structi, mmu_structo);
          if (store_structi != store_structi_previous
              || store_structo != store_structo_previous)
            $fwriteh(store_file, "%d %p %p\n", cyclesToPrint, store_structi, store_structo);
          if (frontend_structi != frontend_structi_previous
              || frontend_structo != frontend_structo_previous)
            $fwriteh(frontend_file, "%d %p %p\n", cyclesToPrint, frontend_structi, frontend_structo);
          if (wt_cache_structi != wt_cache_structi_previous
              || wt_cache_structo != wt_cache_structo_previous)
            $fwriteh(wt_cache_file, "%d %p %p\n", cyclesToPrint, wt_cache_structi, wt_cache_structo);
          if (wt_icache_structi != wt_icache_structi_previous
              || wt_icache_structo != wt_icache_structo_previous)
            $fwriteh(wt_icache_file, "%d %p %p\n", cyclesToPrint, wt_icache_structi, wt_icache_structo);
          if (wt_dcache_missunit_structi != wt_dcache_missunit_structi_previous
              || wt_dcache_missunit_structo != wt_dcache_missunit_structo_previous)
            $fwriteh(wt_dcache_missunit_file, "%d %p %p\n", cyclesToPrint, wt_dcache_missunit_structi, wt_dcache_missunit_structo);
          if (wt_axi_adapter_structi != wt_axi_adapter_structi_previous
              || wt_axi_adapter_structo != wt_axi_adapter_structo_previous)
            $fwriteh(wt_axi_adapter_file, "%d %p %p\n", cyclesToPrint, wt_axi_adapter_structi, wt_axi_adapter_structo);
          if (wt_dcache_ctrl_structi != wt_dcache_ctrl_structi_previous
              || wt_dcache_ctrl_structo != wt_dcache_ctrl_structo_previous)
            $fwriteh(wt_dcache_ctrl_file, "%d %p %p\n", cyclesToPrint, wt_dcache_ctrl_structi, wt_dcache_ctrl_structo);
          if (wt_dcache_mem_structi != wt_dcache_mem_structi_previous
              || wt_dcache_mem_structo != wt_dcache_mem_structo_previous)
            $fwriteh(wt_dcache_mem_file, "%d %p %p\n", cyclesToPrint, wt_dcache_mem_structi, wt_dcache_mem_structo);
          if (wt_dcache_wbuffer_structi != wt_dcache_wbuffer_structi_previous
              || wt_dcache_wbuffer_structo != wt_dcache_wbuffer_structo_previous)
            $fwriteh(wt_dcache_wbuffer_file, "%d %p %p\n", cyclesToPrint, wt_dcache_wbuffer_structi, wt_dcache_wbuffer_structo);
          if (alu_structi != alu_structi_previous
              || alu_structo != alu_structo_previous)
            $fwriteh(alu_file, "%d %p %p\n", cyclesToPrint, alu_structi, alu_structo);
          if (id_stage_structi != id_stage_structi_previous
              || id_stage_structo != id_stage_structo_previous)
            $fwriteh(id_stage_file, "%d %p %p\n", cyclesToPrint, id_stage_structi, id_stage_structo);
          if (dm_csrs_structi != dm_csrs_structi_previous
              || dm_csrs_structo != dm_csrs_structo_previous)
            $fwriteh(dm_csrs_file, "%d %p %p\n", cyclesToPrint, dm_csrs_structi, dm_csrs_structo);
          if (dm_mem_structi != dm_mem_structi_previous
              || dm_mem_structo != dm_mem_structo_previous)
            $fwriteh(dm_mem_file, "%d %p %p\n", cyclesToPrint, dm_mem_structi, dm_mem_structo);
          if (sram_structi != sram_structi_previous
              || sram_structo != sram_structo_previous)
            $fwriteh(sram_file, "%d %p %p\n", cyclesToPrint, sram_structi, sram_structo);
          if (signal_struct != signal_struct_previous)
            $fwriteh(signal_file, "%d %p\n", cyclesToPrint, signal_struct);
          if (ptw_struct != ptw_struct_previous)
            $fwriteh(ptw_file, "%d %p\n", cyclesToPrint, ptw_struct);
          if (scoreboard_struct != scoreboard_struct_previous)
            $fwriteh(scoreboard_file, "%d %p\n", cyclesToPrint, scoreboard_struct);
          if (decoder_struct != decoder_struct_previous)
            $fwriteh(decoder_file, "%d %p\n", cyclesToPrint, decoder_struct);
    end

    ariane_structi_previous <= ariane_structi;
    ariane_structo_previous <= ariane_structo;
    branch_structi_previous <= branch_structi;
    branch_structo_previous <= branch_structo;
    commit_structi_previous <= commit_structi;
    commit_structo_previous <= commit_structo;
    controller_structi_previous <= controller_structi;
    csr_regfile_structi_previous <= csr_regfile_structi;
    csr_regfile_structo_previous <= csr_regfile_structo;
    issue_read_operands_structi_previous <= issue_read_operands_structi;
    issue_read_operands_structo_previous <= issue_read_operands_structo;
    issue_stage_structi_previous <= issue_stage_structi;
    issue_stage_structo_previous <= issue_stage_structo;
    load_store_structi_previous <= load_store_structi;
    load_store_structo_previous <= load_store_structo;
    lsu_bypass_structi_previous <= lsu_bypass_structi;
    lsu_bypass_structo_previous <= lsu_bypass_structo;
    mmu_structi_previous <= mmu_structi;
    mmu_structo_previous <= mmu_structo;
    store_structi_previous <= store_structi;
    store_structo_previous <= store_structo;
    frontend_structi_previous <= frontend_structi;
    frontend_structo_previous <= frontend_structo;
    wt_cache_structi_previous <= wt_cache_structi;
    wt_cache_structo_previous <= wt_cache_structo;
    wt_icache_structi_previous <= wt_icache_structi;
    wt_icache_structo_previous <= wt_icache_structo;
    wt_dcache_missunit_structi_previous <= wt_dcache_missunit_structi;
    wt_dcache_missunit_structo_previous <= wt_dcache_missunit_structo;
    wt_axi_adapter_structi_previous <= wt_axi_adapter_structi;
    wt_axi_adapter_structo_previous <= wt_axi_adapter_structo;
    wt_dcache_ctrl_structi_previous <= wt_dcache_ctrl_structi;
    wt_dcache_ctrl_structo_previous <= wt_dcache_ctrl_structo;
    wt_dcache_mem_structi_previous <= wt_dcache_mem_structi;
    wt_dcache_mem_structo_previous <= wt_dcache_mem_structo;
    wt_dcache_wbuffer_structi_previous <= wt_dcache_wbuffer_structi;
    wt_dcache_wbuffer_structo_previous <= wt_dcache_wbuffer_structo;
    alu_structi_previous <= alu_structi;
    alu_structo_previous <= alu_structo;
    id_stage_structi_previous <= id_stage_structi;
    id_stage_structo_previous <= id_stage_structo;
    dm_csrs_structi_previous <= dm_csrs_structi;
    dm_csrs_structo_previous <= dm_csrs_structo;
    dm_mem_structi_previous <= dm_mem_structi;
    dm_mem_structo_previous <= dm_mem_structo;
    sram_structi_previous <= sram_structi;
    sram_structo_previous <= sram_structo;
    signal_struct_previous <= signal_struct;
    ptw_struct_previous <= ptw_struct;
    scoreboard_struct_previous <= scoreboard_struct;
    decoder_struct_previous <= decoder_struct;
  end

  final begin
    $fclose(ariane_file);
    $fclose(branch_file);
    $fclose(commit_file);
    $fclose(controller_file);
    $fclose(csr_regfile_file);
    $fclose(issue_read_operands_file);
    $fclose(issue_stage_file);
    $fclose(load_store_file);
    $fclose(lsu_bypass_file);
    $fclose(mmu_file);
    $fclose(store_file);
    $fclose(frontend_file);
    $fclose(wt_cache_file);
    $fclose(wt_icache_file);
    $fclose(wt_dcache_missunit_file);
    $fclose(wt_axi_adapter_file);
    $fclose(wt_dcache_ctrl_file);
    $fclose(wt_dcache_mem_file);
    $fclose(wt_dcache_wbuffer_file);
    $fclose(alu_file);
    $fclose(id_stage_file);
    $fclose(dm_mem_file);
    $fclose(sram_file);
    $fclose(signal_file);
    $fclose(ptw_file);
    $fclose(scoreboard_file);
    $fclose(decoder_file);
    $fclose(dm_csrs_file);
  end
`endif // VERILATOR

// synthesis translate_on

endmodule // debug_ip

