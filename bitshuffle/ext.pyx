import numpy as np

cimport numpy as np
cimport cython


np.import_array()


# Repeat each calcualtion this many times. For timeing.
cdef int REPEATC = 1
REPEAT = REPEATC

cdef extern from "bitshuffle.h":
    int bshuf_using_SSE2()
    int bshuf_using_AVX2()
    int bshuf_bitshuffle(void *A, void *B, int size, int elem_size,
            int block_size)
    int bshuf_bitunshuffle(void *A, void *B, int size, int elem_size,
            int block_size)
    int bshuf_compress_lz4_bound(int size, int elem_size, int block_size)
    int bshuf_compress_lz4(void *A, void *B, int size, int elem_size,
            int block_size)
    int bshuf_decompress_lz4(void *A, void *B, int size, int elem_size,
            int block_size)

# Prototypes from bitshuffle.c
cdef extern int bshuf_copy(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_byte_elem_scal(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_byte_elem_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_byte_scal(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_byte_scal_unrolled(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_byte_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_byte_AVX(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_byte_AVX_unrolled(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bitrow_eight(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_elem_AVX(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_elem_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_elem_scal(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_byte_bitrow_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_byte_bitrow(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_shuffle_bit_eightelem_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_untrans_bit_elem_SSE(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_untrans_bit_elem_scal(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_trans_bit_elem(void *A, void *B, int size, int elem_size)
cdef extern int bshuf_untrans_bit_elem(void *A, void *B, int size, int elem_size)


ctypedef int (*Cfptr) (void *A, void *B, int size, int elem_size)


def using_SSE2():
    if bshuf_using_SSE2():
        return True
    else:
        return False


def using_AVX2():
    if bshuf_using_AVX2():
        return True
    else:
        return False


def _setup_arr(arr):
    shape = tuple(arr.shape)
    if not arr.flags['C_CONTIGUOUS']:
        msg = "Input array must be C-contiguouse."
        raise ValueError(msg)
    size = arr.size
    dtype = arr.dtype
    itemsize = dtype.itemsize
    out = np.empty(shape, dtype=dtype)
    return out, size, itemsize


cdef _wrap_C_fun(Cfptr fun, np.ndarray arr):
    """Wrap a C function with standard call signature."""

    cdef int ii, size, itemsize, count
    cdef np.ndarray out
    out, size, itemsize = _setup_arr(arr)
    cdef void* arr_ptr = <void*> arr.data
    cdef void* out_ptr = <void*> out.data
    for ii in range(REPEATC):
        count = fun(arr_ptr, out_ptr, size, itemsize)
    if count < 0:
        msg = "Failed. Error code %d."
        excp = RuntimeError(msg % count, count)
        raise excp
    return out


def copy(np.ndarray arr not None):
    """Copies the data.

    For testing and profiling purposes.

    """
    return _wrap_C_fun(&bshuf_copy, arr)


def trans_byte_elem_scal(np.ndarray arr not None):
    """Transpose bytes within words but not bits.

    """
    return _wrap_C_fun(&bshuf_trans_byte_elem_scal, arr)


def trans_byte_elem_SSE(np.ndarray arr not None):
    """Transpose bytes within array elements.

    """
    return _wrap_C_fun(&bshuf_trans_byte_elem_SSE, arr)


def trans_bit_byte_scal(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_byte_scal, arr)


def trans_bit_byte_scal_unrolled(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_byte_scal_unrolled, arr)


def trans_bit_byte_SSE(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_byte_SSE, arr)


def trans_bit_byte_AVX(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_byte_AVX, arr)


def trans_bit_byte_AVX_unrolled(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_byte_AVX_unrolled, arr)


def trans_bitrow_eight(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bitrow_eight, arr)


def trans_bit_elem_AVX(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_elem_AVX, arr)


def trans_bit_elem_scal(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_elem_scal, arr)


def trans_bit_elem_SSE(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_elem_SSE, arr)


def trans_byte_bitrow_SSE(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_byte_bitrow_SSE, arr)


def trans_byte_bitrow(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_byte_bitrow, arr)


def shuffle_bit_eightelem_SSE(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_shuffle_bit_eightelem_SSE, arr)


def untrans_bit_elem_SSE(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_untrans_bit_elem_SSE, arr)


def untrans_bit_elem_scal(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_untrans_bit_elem_scal, arr)


def trans_bit_elem(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_trans_bit_elem, arr)


def untrans_bit_elem(np.ndarray arr not None):
    return _wrap_C_fun(&bshuf_untrans_bit_elem, arr)


def bitshuffle(np.ndarray arr not None, int block_size=0):
    """Bitshuffle an array.

    Output array is the same shape and datatype as input array but underlying
    buffer has been bitshuffled.

    """

    cdef int ii, size, itemsize, count
    cdef np.ndarray out
    out, size, itemsize = _setup_arr(arr)
    cdef void* arr_ptr = <void*> arr.data
    cdef void* out_ptr = <void*> out.data
    for ii in range(REPEATC):
        count = bshuf_bitshuffle(arr_ptr, out_ptr, size, itemsize, block_size)
    if count < 0:
        msg = "Failed. Error code %d."
        excp = RuntimeError(msg % count, count)
        raise excp
    return out


def bitunshuffle(np.ndarray arr not None, int block_size=0):
    """Bitshuffle an array.

    Output array is the same shape and datatype as input array but underlying
    buffer has been un-bitshuffled.

    """

    cdef int ii, size, itemsize, count
    cdef np.ndarray out
    out, size, itemsize = _setup_arr(arr)
    cdef void* arr_ptr = <void*> arr.data
    cdef void* out_ptr = <void*> out.data
    for ii in range(REPEATC):
        count = bshuf_bitunshuffle(arr_ptr, out_ptr, size, itemsize, block_size)
    if count < 0:
        msg = "Failed. Error code %d."
        excp = RuntimeError(msg % count, count)
        raise excp
    return out


def compress_lz4(np.ndarray arr not None, int block_size=0):
    """Bitshuffle then compress an array using LZ4.

    Returns
    -------
    out : array with np.uint8 datatype
        Buffer holding compressed data.

    """

    cdef int ii, size, itemsize, count
    shape = (arr.shape[i] for i in range(arr.ndim))
    if not arr.flags['C_CONTIGUOUS']:
        msg = "Input array must be C-contiguouse."
        raise ValueError(msg)
    size = arr.size
    dtype = arr.dtype
    itemsize = dtype.itemsize

    max_out_size = bshuf_compress_lz4_bound(size, itemsize, block_size)

    cdef np.ndarray out
    out = np.empty(max_out_size, dtype=np.uint8)

    cdef void* arr_ptr = <void*> arr.data
    cdef void* out_ptr = <void*> out.data
    for ii in range(REPEATC):
        count = bshuf_compress_lz4(arr_ptr, out_ptr, size, itemsize, block_size)
    if count < 0:
        msg = "Failed. Error code %d."
        excp = RuntimeError(msg % count, count)
        raise excp
    return out[:count]


def decompress_lz4(np.ndarray arr not None, shape, dtype, int block_size=0):
    """Domcompress a buffer using LZ4 then bitunshuffle it yeilding an array.

    Parameters
    ----------
    buf : buffer
        Input data to be decompressed.
    shape : tuple of integers
        Shape of the output (decompressed array).
    dtype : numpy dtype
        Datatype of the output array

    """

    cdef int ii, size, itemsize, count
    if not arr.flags['C_CONTIGUOUS']:
        msg = "Input array must be C-contiguouse."
        raise ValueError(msg)
    size = np.prod(shape)
    itemsize = dtype.itemsize

    cdef np.ndarray out
    out = np.empty(tuple(shape), dtype=dtype)

    cdef void* arr_ptr = <void*> arr.data
    cdef void* out_ptr = <void*> out.data
    for ii in range(REPEATC):
        count = bshuf_decompress_lz4(arr_ptr, out_ptr, size, itemsize,
                                     block_size)
    if count < 0:
        msg = "Failed. Error code %d."
        excp = RuntimeError(msg % count, count)
        raise excp
    if count != arr.size:
        msg = "Decompressed different number of bytes than input buffer size."
        msg += "Input buffer %d, decompressed %d." % (arr.size, count)
        raise RuntimeError(msg, count)
    return out


