class FindMap(gdb.Command):
	"""Find memory mapping, source file and offset corresponding to address"""
	def __init__(self):
		super(FindMap, self).__init__("findmap", gdb.COMMAND_USER, gdb.COMPLETE_EXPRESSION)
	
	def invoke(self, arg, from_tty):
		arg = int(gdb.parse_and_eval('(unsigned long long)('+arg+')'))
		lines = gdb.execute("info proc mappings", from_tty, True).split('\n')
		header = ''
		foundStart = False
		for line in lines:
			if foundStart and '0x' in line:
				fields = line.split()
				start = int(fields[0], 16)
				end   = int(fields[1], 16)
				if start <= arg and arg < end:
					map_offset = int(fields[3], 16)
					ptr_offset = arg - start
					file = fields[5] if len(fields) > 5 else "<anonymous>"
					print("Mapping:")
					print(header)
					print(line)
					print("Origin:", file, "+", hex(ptr_offset+map_offset))
			elif 'Start Addr' in line and 'End Addr' in line:
				foundStart = True
				header = line

FindMap()
