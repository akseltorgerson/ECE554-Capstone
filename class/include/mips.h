//////////////////////////////////////////////////////////////////////////////
//
//    CLASS - Cloud Loader and ASsembler System
//    Copyright (C) 2021 Winor Chen
//
//    This program is free software; you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation; either version 2 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License along
//    with this program; if not, write to the Free Software Foundation, Inc.,
//    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef __MIPS_H__
#define __MIPS_H__


/* A header for mips specifc details
 * such as register name mappings
 * and a jump list for functional routines
 *
 * Instruction Formats:
 * R - 6 opcode, 5 rs, 5 rt, 5 rd, 5 shamt, 6 funct
 * I - 6 opcode, 5 rs, 5 rt, 16 imm
 * J - 6 opcode, 26 addr
 *
 *
 * wchen329
 */
#include <cstring>
#include <cstddef>
#include <memory>
#include "ISA.h"
#include "mt_exception.h"
#include "primitives.h"
#include "priscas_global.h"
#include "syms_table.h"
#include "ustrop.h"

namespace priscas
{

	// Friendly Register Names -> Numerical Assignments
	enum REGISTERS
	{
		$zero = 0,
		$at = 1,
		$v0 = 2,
		$v1 = 3,
		$a0 = 4,
		$a1 = 5,
		$a2 = 6,
		$a3 = 7,
		$t0 = 8,
		$t1 = 9,
		$t2 = 10,
		$t3 = 11,
		$t4 = 12,
		$t5 = 13,
		$t6 = 14,
		$t7 = 15,
		$s0 = 16,
		$s1 = 17,
		$s2 = 18,
		$s3 = 19,
		$s4 = 20,
		$s5 = 21,
		$s6 = 22,
		$s7 = 23,
		$t8 = 24,
		$t9 = 25,
		$k0 = 26,
		$k1 = 27,
		$gp = 28,
		$sp = 29,
		$fp = 30,
		$ra = 31,
		INVALID = -1
	};


	// MIPS Processor Opcodes
	enum opcode
	{

		HALT = 0,
		NOP = 1,
		STARTF = 2,
		STARTI = 3,
		LOADF = 31,


		// I INSTRUCTIONS 1
		// 3 + opcode
		ADDI = 8,
		SUBI = 9,
		XORI = 10,
		ANDNI = 11,
		ST = 16,
		LD = 17,
		STU = 19,

		// I INSTRUCTIONS 2
		// 2 + opcode
		
		JR = 5,
		JALR = 7,
		LBI = 20,
		SLBI = 18,

		BEQZ = 12,
		BNEZ = 13,
		BLTZ = 14,
		BGEZ = 15,


		// J INSTRUCTIONS
		J = 4,
		JAL = 6,

		// R Format

		ADD = 24,
		SUB = 25,
		XOR = 26,
		ANDN = 27,
		SEQ = 28,
		SLT = 29,
		SLE = 30,
		
		SYS_RES = -1	// system reserved for shell interpreter
	};


	int friendly_to_numerical(const char *);

	// From a register specifier, i.e. %so get an integer representation
	int get_reg_num(const char *);

	// From a immediate string, get an immediate value.
	int get_imm(const char *);

	namespace ALU
	{
		enum ALUOp
		{
					ADD = 0,
					SUB = 1,
					ANDN = 2,
					XOR = 3
		};
	}

	// Format check functions
	/* Checks if an instruction is I formatted.
	 */
	bool i_inst1(opcode operation);

	bool i_inst2(opcode operation);

	/* Checks if an instruction is R formatted.
	 */
	bool r_inst(opcode operation);

	/* Checks if an instruction is J formatted.
	 */
	bool j_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory access
	 */
	bool mem_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory write
	 */
	bool mem_write_inst(opcode operation);

	/* Checks if an instruction performs
	 * memory read
	 */
	bool mem_read_inst(opcode operation);

	/* Checks if an instruction performs
	 * a register write
	 */
	bool reg_write_inst(opcode operation);

	/* Check if a special R-format
	 * shift instruction
	 */
	bool shift_inst(opcode operation);

	/* Check if a Jump or
	 * Branch Instruction
	 */
	bool jorb_inst(opcode operation);

	/* "Generic" MIPS-32 architecture
	 * encoding function asm -> binary
	 */
	BW_32 generic_mips32_encode(int rs, int rt, int rd, int imm_shamt_jaddr, opcode op, int filter, uint32_t signum);

	/* For calculating a label offset in branches
	 */
	BW_32 offset_to_address_br(BW_32 current, BW_32 target);

	/* MIPS_32 ISA
	 *
	 */
	class MIPS_32 : public ISA
	{
		
		public:
			virtual std::string get_reg_name(int id);
			virtual int get_reg_id(std::string& fr) { return friendly_to_numerical(fr.c_str()); }
			virtual ISA_Attrib::endian get_endian() { return ISA_Attrib::CPU_BIG_ENDIAN; }
			virtual mBW assemble(const Arg_Vec& args, const BW& baseAddress, syms_table& jump_syms) const;
		private:
			static const unsigned REG_COUNT = 32;
			static const unsigned PC_BIT_WIDTH = 32;
			static const unsigned UNIVERSAL_REG_BW = 32;
	};
}

#endif
