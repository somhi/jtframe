	//registers used:
		//r1: yes
		//r2: yes
		//r3: yes
		//r4: no
		//r5: no
		//r6: no
		//r7: no
		//tmp: no
	.section	.text.2
	.global	_addchar
_addchar:
	stdec	r6
	mt	r3
	stdec	r6
						// allocreg r3
						// allocreg r1
						// Q1 disposable
		// Offsets 0, 0
		// Have am? yes, no
		// flags 40, 42
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 0
		// Real offset of type is 0, isauto 0
						// (prepobj r0)
 						// reg r3 - no need to prep
						// (obj to tmp) flags 40 type 101
						// reg r1 - only match against tmp
	mt	r1
						// (save temp)isreg
	mr	r3
						//save_temp done
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 9
		// Real offset of type is 9, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 40
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 40
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Deferred popping of 0 bytes (0 in total)
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Q1 disposable
						// Z disposable
		// Offsets 0, 0
		// Have am? yes, yes
		// flags 42, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 25
		// Real offset of type is 25, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 42 type 101
						// matchobj comparing flags 42 with 1
						// reg r3 - only match against tmp
	mt	r3
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 42
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 42
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 29
		// Real offset of type is 29, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
						// freereg r3
	ldinc	r6
	mr	r3

	ldinc	r6
	mr	r7

	//registers used:
		//r1: yes
		//r2: yes
		//r3: no
		//r4: no
		//r5: no
		//r6: no
		//r7: no
		//tmp: no
	.section	.text.3
	.global	_main
_main:
	stdec	r6
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 38
		// Offsets 0, 0
		// Have am? no, no
		// flags 1, 2
						// (a/p assign)
						// Destination is a variable with offset 0, 0
		// Real offset of type is 0, isauto 0
						// (prepobj r0)
 						// (prepobj r0)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe not varadr
	mr	r0
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r0
						//Disposable, postinc doesn't matter.
						//save_temp done

						//comparisons.c, line 40
						// (compare) (q1 signed) (q2 signed)
						// (obj to r0) flags 2 type 3
						// matchobj comparing flags 2 with 1
						// matchobj comparing flags 2 with 82
						// extern
	.liabs	_st
						//extern deref
						//sizemod based on type 0x3
	ldt
	mr	r0
						// (obj to tmp) flags 2 type 3
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 4
						//extern deref
						//sizemod based on type 0x3
	ldt
	sgn
	cmp	r0

						//comparisons.c, line 40
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l6
		add	r7
						// freereg r1
						// freereg r2
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 5
		// Real offset of type is 5, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 2
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 2
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 48, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 21
		// Real offset of type is 21, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	48
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 25
		// Real offset of type is 25, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 40
						//pcreltotemp
	.lipcrel	l44
	add	r7
l6: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 34
		// Real offset of type is 34, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 65, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 50
		// Real offset of type is 50, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	65
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 54
		// Real offset of type is 54, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l44: # 
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 41
						// (compare) (q1 unsigned) (q2 unsigned)
						// (obj to r0) flags 2 type 103
						// extern
	.liabs	_st, 8
						//extern deref
						//sizemod based on type 0x103
	ldt
	mr	r0
						// (obj to tmp) flags 2 type 103
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 12
						//extern deref
						//sizemod based on type 0x103
	ldt
	cmp	r0

						//comparisons.c, line 41
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l9
		add	r7
						// freereg r1
						// freereg r2
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 63
		// Real offset of type is 63, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 2
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 2
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 49, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 79
		// Real offset of type is 79, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	49
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 83
		// Real offset of type is 83, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 41
						//pcreltotemp
	.lipcrel	l46
	add	r7
l9: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 92
		// Real offset of type is 92, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 66, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 108
		// Real offset of type is 108, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	66
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 112
		// Real offset of type is 112, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l46: # 
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 42
						//FIXME convert
						// (convert - reducing type 3 to 103
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 3
						// extern
	.liabs	_st
						//extern deref
						//sizemod based on type 0x3
	ldt
						//Saving to reg r1
						// (save temp)isreg
	mr	r1
						//save_temp done
						//No need to mask - same size

						//comparisons.c, line 42
						// Q1 disposable
						// (compare) (q1 unsigned) (q2 unsigned)
						// (obj to tmp) flags 2 type 103
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 8
						//extern deref
						//sizemod based on type 0x103
	ldt
	cmp	r1
						// freereg r1

						//comparisons.c, line 42
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l12
		add	r7
						// freereg r2
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 121
		// Real offset of type is 121, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 2
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 2
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 50, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 137
		// Real offset of type is 137, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	50
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 141
		// Real offset of type is 141, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 42
						//pcreltotemp
	.lipcrel	l48
	add	r7
l12: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 150
		// Real offset of type is 150, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 67, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 166
		// Real offset of type is 166, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	67
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 170
		// Real offset of type is 170, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l48: # 
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 43
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r1)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 101
						// extern
	.liabs	_st, 16
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 43
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 2 type 3
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st
						//extern deref
						//sizemod based on type 0x3
	ldt
	sgn
	cmp	r1
						// freereg r1

						//comparisons.c, line 43
	cond	LE
						//conditional branch reversed
						//pcreltotemp
	.lipcrel	l15
		add	r7
						// freereg r2
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 179
		// Real offset of type is 179, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 2
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 2
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 51, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 195
		// Real offset of type is 195, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	51
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 199
		// Real offset of type is 199, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 43
						//pcreltotemp
	.lipcrel	l50
	add	r7
l15: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 208
		// Real offset of type is 208, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 68, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 224
		// Real offset of type is 224, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	68
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 228
		// Real offset of type is 228, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l50: # 
						// allocreg r2

						//comparisons.c, line 44
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r2)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 2 type 101
						// extern
	.liabs	_st, 16
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 44
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r1)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 101
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 17
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 44
						// Q1 disposable
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 4a type 3
						// matchobj comparing flags 4a with 2
						// reg r1 - only match against tmp
	//mt
	sgn
	cmp	r2
						// freereg r2
						// freereg r1

						//comparisons.c, line 44
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l18
		add	r7
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 237
		// Real offset of type is 237, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 52, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 253
		// Real offset of type is 253, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	52
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 257
		// Real offset of type is 257, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 44
						//pcreltotemp
	.lipcrel	l52
	add	r7
l18: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 266
		// Real offset of type is 266, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 69, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 282
		// Real offset of type is 282, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	69
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 286
		// Real offset of type is 286, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l52: # 
						// allocreg r2

						//comparisons.c, line 45
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r2)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 2 type 101
						// extern
	.liabs	_st, 18
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 45
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r1)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 101
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 19
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 45
						// Q1 disposable
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 4a type 3
						// matchobj comparing flags 4a with 2
						// reg r1 - only match against tmp
	//mt
	sgn
	cmp	r2
						// freereg r2
						// freereg r1

						//comparisons.c, line 45
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l21
		add	r7
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 295
		// Real offset of type is 295, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 53, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 311
		// Real offset of type is 311, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	53
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 315
		// Real offset of type is 315, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 45
						//pcreltotemp
	.lipcrel	l54
	add	r7
l21: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 324
		// Real offset of type is 324, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 70, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 340
		// Real offset of type is 340, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	70
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 344
		// Real offset of type is 344, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l54: # 
						// allocreg r2

						//comparisons.c, line 46
						//FIXME convert
						//Converting to wider type...
						// (obj to r2) flags 2 type 2
						// extern
	.liabs	_st, 20
						//extern deref
						//sizemod based on type 0x2
	hlf
	ldt
	mr	r2
						// matchobj comparing flags 1 with 2
	.liconst	-32768
	add	r2
	xor	r2
						// (save result) // isreg
						// allocreg r1

						//comparisons.c, line 46
						//FIXME convert
						//Converting to wider type...
						// (obj to r1) flags 2 type 2
						// matchobj comparing flags 2 with 1
						// extern
	.liabs	_st, 22
						//extern deref
						//sizemod based on type 0x2
	hlf
	ldt
	mr	r1
						// matchobj comparing flags 1 with 2
	.liconst	-32768
	add	r1
	xor	r1
						// (save result) // isreg

						//comparisons.c, line 46
						// Q1 disposable
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 4a type 3
						// matchobj comparing flags 4a with 1
						// reg r1 - only match against tmp
	mt	r1
	sgn
	cmp	r2
						// freereg r2
						// freereg r1

						//comparisons.c, line 46
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l24
		add	r7
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 353
		// Real offset of type is 353, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 54, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 369
		// Real offset of type is 369, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	54
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 373
		// Real offset of type is 373, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 46
						//pcreltotemp
	.lipcrel	l56
	add	r7
l24: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 382
		// Real offset of type is 382, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 71, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 398
		// Real offset of type is 398, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	71
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 402
		// Real offset of type is 402, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l56: # 
						// allocreg r2

						//comparisons.c, line 47
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r2)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 2 type 102
						// extern
	.liabs	_st, 24
						//extern deref
						//sizemod based on type 0x102
	hlf
	ldt
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 47
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r1)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 102
						// matchobj comparing flags 2 with 2
						// extern
	.liabs	_st, 26
						//extern deref
						//sizemod based on type 0x102
	hlf
	ldt
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 47
						// Q1 disposable
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 4a type 3
						// matchobj comparing flags 4a with 2
						// reg r1 - only match against tmp
	//mt
	sgn
	cmp	r2
						// freereg r2
						// freereg r1

						//comparisons.c, line 47
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l27
		add	r7
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 411
		// Real offset of type is 411, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 55, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 427
		// Real offset of type is 427, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	55
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 431
		// Real offset of type is 431, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 47
						//pcreltotemp
	.lipcrel	l58
	add	r7
l27: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 440
		// Real offset of type is 440, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 72, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 456
		// Real offset of type is 456, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	72
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 460
		// Real offset of type is 460, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l58: # 

						//comparisons.c, line 49
		// Offsets 28, 16
		// Have am? no, no
		// flags 1, 2
						// (a/p assign)
						// Destination is a variable with offset 16, 0
		// Real offset of type is 16, isauto 0
						// (prepobj r0)
 						// (prepobj r0)
 						// extern (offset 16)
	.liabs	_st, 16
						// extern pe not varadr
	mr	r0
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
						// matchobj comparing flags 1 with 82
	.liconst	28
						// (save temp)store type 1
	stbinc	r0
						//Disposable, postinc doesn't matter.
						//save_temp done
						// allocreg r2

						//comparisons.c, line 50
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r2)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 2 type 101
						// matchobj comparing flags 2 with 1
						// matchobj comparing flags 2 with 82
						// extern
	.liabs	_st, 16
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 50
						//FIXME convert
						//Converting to wider type...
						//But unsigned, so no need to extend
						// (prepobj r1)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 2 type 101
						// matchobj comparing flags 2 with 2
						// matchobj comparing flags 2 with 82
						// extern
	.liabs	_st, 17
						//extern deref
						//sizemod based on type 0x101
	byt
	ldt
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 50
						// Q1 disposable
						// Q2 disposable
						// (compare) (q1 signed) (q2 signed)
						// (obj to tmp) flags 4a type 3
						// matchobj comparing flags 4a with 2
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	//mt
	sgn
	cmp	r2
						// freereg r2
						// freereg r1

						//comparisons.c, line 50
	cond	GE
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l30
		add	r7
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 469
		// Real offset of type is 469, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// matchobj comparing flags 82 with 82
						//extern: comparing 0 with 17
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// matchobj comparing flags 82 with 82
						//extern: comparing 0 with 17
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 56, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 485
		// Real offset of type is 485, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	56
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 489
		// Real offset of type is 489, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1

						//comparisons.c, line 50
						//pcreltotemp
	.lipcrel	l60
	add	r7
l30: # 
						// allocreg r1

						//comparisons.c, line 31
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 498
		// Real offset of type is 498, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 31
						//call
						//pcreltotemp
	.lipcrel	___strlen // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r1
						// allocreg r1

						//comparisons.c, line 31
						// (getreturn)						// (save result) // isreg
	mt	r0
	mr	r1

						//comparisons.c, line 31
						//FIXME convert
						// (convert - reducing type 103 to 3
						//No need to mask - same size
						// allocreg r2

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 0, 2, 3
						// (obj to r2) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj r2)
 						// (prepobj r2)
 						// matchobj comparing flags 82 with 4a
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	mr	r2
						// (obj to tmp) flags 4a type a
						// matchobj comparing flags 4a with 82
						// reg r1 - only match against tmp
	mt	r1
	add	r2
						// (save result) // isreg

						//comparisons.c, line 32
						// (bitwise/arithmetic) 	//ops: 2, 0, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 1 type 3
						// matchobj comparing flags 1 with 4a
						// const
						// matchobj comparing flags 1 with 4a
	.liconst	1
	add	r1
						// (save result) // isreg

						//comparisons.c, line 32
						// Z disposable
		// Offsets 73, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 514
		// Real offset of type is 514, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 1
						// const
						// matchobj comparing flags 1 with 1
	.liconst	73
						// (save temp)store type 1
	stbinc	r2
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r2

						//comparisons.c, line 33
						// (bitwise/arithmetic) 	//ops: 0, 2, 2
						// WARNING - q1 and target collision - check code for correctness.
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 1
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 1
						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	add	r1
						// (save result) // isreg

						//comparisons.c, line 33
						// Z disposable
		// Offsets 0, 0
		// Have am? no, yes
		// flags 1, 6a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 518
		// Real offset of type is 518, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 1 type 101
						// matchobj comparing flags 1 with 82
						// const
						// matchobj comparing flags 1 with 82
	.liconst	0
						// (save temp)store type 1
	stbinc	r1
						//Disposable, postinc doesn't matter.
						//save_temp done
						// freereg r1
l60: # 
						// allocreg r2

						//comparisons.c, line 52
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 208
		// Real offset of type is 208, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 52
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 212
		// Real offset of type is 212, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 82
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 82
						// static
	.liabs	l34,0
						// static pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 52
						//call
						//pcreltotemp
	.lipcrel	___strcmp // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r2
						// freereg r1
						// allocreg r1

						//comparisons.c, line 52
						// (test)
						// (obj to tmp) flags 4a type 3
						// reg r0 - only match against tmp
	mt	r0
				// flags 4a
	and	r0
						// freereg r1

						//comparisons.c, line 52
	cond	NEQ
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l33
		add	r7
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 53
						// (a/p push)
						// a: pushed 0, regnames[sp] r6
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// static
	.liabs	l35,0
						// static pe is varadr
	stdec	r6

						//comparisons.c, line 53
						//call
						//pcreltotemp
	.lipcrel	_printf // extern
	add	r7
						// Flow control - popping 4 + 0 bytes
	.liconst	4
	add	r6

						//comparisons.c, line 54
						//pcreltotemp
	.lipcrel	l41
	add	r7
						// freereg r1
						// freereg r2
l33: # 
						// allocreg r2

						//comparisons.c, line 54
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 232
		// Real offset of type is 232, isauto 0
						// (prepobj r0)
 						// reg r2 - no need to prep
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
						// (save temp)isreg
	mr	r2
						//save_temp done
						// allocreg r1

						//comparisons.c, line 54
		// Offsets 0, 0
		// Have am? no, no
		// flags 82, 4a
						// (a/p assign)
						// Destination is a register...
						// Destination is a variable with offset 0, 236
		// Real offset of type is 236, isauto 0
						// (prepobj r0)
 						// reg r1 - no need to prep
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 82
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 82
						// static
	.liabs	l39,0
						// static pe is varadr
						// (save temp)isreg
	mr	r1
						//save_temp done

						//comparisons.c, line 54
						//call
						//pcreltotemp
	.lipcrel	___strcmp // extern
	add	r7
						// Flow control - popping 0 + 0 bytes
						// freereg r2
						// freereg r1
						// allocreg r1

						//comparisons.c, line 54
						// (test)
						// (obj to tmp) flags 4a type 3
						// reg r0 - only match against tmp
	mt	r0
				// flags 4a
	and	r0
						// freereg r1

						//comparisons.c, line 54
	cond	NEQ
						//conditional branch regular
						//pcreltotemp
	.lipcrel	l38
		add	r7
						// allocreg r2
						// allocreg r1

						//comparisons.c, line 55
						// (a/p push)
						// a: pushed 0, regnames[sp] r6
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 4a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 4a
						// static
	.liabs	l40,0
						// static pe is varadr
	stdec	r6

						//comparisons.c, line 55
						//call
						//pcreltotemp
	.lipcrel	_printf // extern
	add	r7
						// Flow control - popping 4 + 0 bytes
	.liconst	4
	add	r6

						//comparisons.c, line 57
						//pcreltotemp
	.lipcrel	l41
	add	r7
l38: # 

						//comparisons.c, line 57
						// (a/p push)
						// a: pushed 0, regnames[sp] r6
						// (obj to tmp) flags 82 type a
						// (prepobj tmp)
 						// (prepobj tmp)
 						// extern (offset 0)
	.liabs	_resultstring
						// extern pe is varadr
	stdec	r6

						//comparisons.c, line 57
						// (a/p push)
						// a: pushed 4, regnames[sp] r6
						// (obj to tmp) flags 82 type a
						// matchobj comparing flags 82 with 82
						// (prepobj tmp)
 						// (prepobj tmp)
 						// matchobj comparing flags 82 with 82
						// static
	.liabs	l42,0
						// static pe is varadr
	stdec	r6

						//comparisons.c, line 57
						//call
						//pcreltotemp
	.lipcrel	_printf // extern
	add	r7
						// Flow control - popping 8 + 0 bytes
	.liconst	8
	add	r6
l41: # 

						//comparisons.c, line 61
						//setreturn
						// (obj to r0) flags 1 type 3
						// const
	.liconst	0
	mr	r0
						// freereg r1
						// freereg r2
	ldinc	r6
	mr	r7

	.section	.data.4
	.align	4
	.global	_st
_st:
	.int	-1073741824
	.int	4096
	.int	4294901760
	.int	256
	.byte	156
	.byte	73
	.byte	156
	.byte	73
	.short	4660
	.short	-292
	.short	4660
	.short	65244
	.section	.bss.5
	.align	4
	.global	_resultstring
	.comm	_resultstring,16
	.section	.rodata.6
	.align	4
l34:
	.byte	48
	.byte	66
	.byte	50
	.byte	51
	.byte	52
	.byte	70
	.byte	71
	.byte	55
	.byte	56
	.byte	0
	.section	.rodata.7
	.align	4
l35:
	.byte	27
	.byte	91
	.byte	51
	.byte	50
	.byte	109
	.byte	80
	.byte	97
	.byte	115
	.byte	115
	.byte	101
	.byte	100
	.byte	32
	.byte	40
	.byte	115
	.byte	105
	.byte	103
	.byte	110
	.byte	101
	.byte	100
	.byte	32
	.byte	99
	.byte	104
	.byte	97
	.byte	114
	.byte	41
	.byte	27
	.byte	91
	.byte	48
	.byte	109
	.byte	10
	.byte	0
	.section	.rodata.8
	.align	4
l39:
	.byte	48
	.byte	66
	.byte	50
	.byte	51
	.byte	69
	.byte	70
	.byte	71
	.byte	55
	.byte	56
	.byte	0
	.section	.rodata.9
	.align	4
l40:
	.byte	27
	.byte	91
	.byte	51
	.byte	50
	.byte	109
	.byte	80
	.byte	97
	.byte	115
	.byte	115
	.byte	101
	.byte	100
	.byte	32
	.byte	40
	.byte	117
	.byte	110
	.byte	115
	.byte	105
	.byte	103
	.byte	110
	.byte	101
	.byte	100
	.byte	32
	.byte	99
	.byte	104
	.byte	97
	.byte	114
	.byte	41
	.byte	27
	.byte	91
	.byte	48
	.byte	109
	.byte	10
	.byte	0
	.section	.rodata.a
	.align	4
l42:
	.byte	27
	.byte	91
	.byte	51
	.byte	49
	.byte	109
	.byte	70
	.byte	97
	.byte	105
	.byte	108
	.byte	101
	.byte	100
	.byte	27
	.byte	91
	.byte	48
	.byte	109
	.byte	32
	.byte	45
	.byte	32
	.byte	103
	.byte	111
	.byte	116
	.byte	32
	.byte	37
	.byte	115
	.byte	0
