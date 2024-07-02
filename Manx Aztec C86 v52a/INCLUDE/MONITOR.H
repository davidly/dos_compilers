int 			_intr_sp(int _speed);
void 			monitor(
					void (*_lowpc)(), 
					void (*_highpc)(), 
					unsigned int *_buf, 
					int _pockets, 
					int _nfunc
				);
