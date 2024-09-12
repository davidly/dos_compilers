
Memory_Model EQU 1	-- The memory model to use for these libraries

If Memory_Model = 0 Then
    Pragma Memory_Model(0);
Else -- Memory_Model = 1
    Pragma Memory_Model(1);
End If;
Null
