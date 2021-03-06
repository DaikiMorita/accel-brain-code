# -*- coding: utf-8 -*-
import numpy as np
cimport numpy as np
from pydbm.dbm.deep_boltzmann_machine import DeepBoltzmannMachine
from pydbm.approximation.shape_bm_cd import ShapeBMCD
from pydbm.activation.logistic_function import LogisticFunction
ctypedef np.float64_t DOUBLE_t


class ShapeBoltzmannMachine(DeepBoltzmannMachine):
    '''
    Shape Boltzmann Machine(Shape-BM).
    '''
    def set_readonly(self, value):
        ''' setter '''
        raise TypeError("This property is read-only.")

    # auto-saved shallower visible data points which is reconstructed.
    __visible_points_arr = None

    def get_visible_points_arr(self):
        ''' getter '''
        return self.__visible_points_arr

    visible_points_arr = property(get_visible_points_arr, set_readonly)
    
    # The number of overlapped pixels.
    __overlap_n = 9
    
    # The width of reshaped image.
    __reshaped_w = 12

    def __init__(
        self,
        dbm_builder,
        neuron_assign_list=[],
        activating_function_list=[],
        approximate_interface_list=[],
        double learning_rate=0.01,
        double dropout_rate=0.0,
        int overlap_n=9,
        int reshaped_w=12
    ):
        '''
        Initialize deep boltzmann machine.

        Args:
            dbm_builder:            `    Concrete Builder` in Builder Pattern.
            neuron_assign_list:          The number of neurons in each layers.
            activating_function_list:    Activation function.
            approximate_interface_list:  The object of function approximation.
            learning_rate:               Learning rate.
            dropout_rate:                Dropout rate.
            overlap_n:                   The number of overlapped pixels.
            reshaped_w:                  The width of reshaped image.
        '''
        self.__overlap_n = overlap_n
        self.__reshaped_w = reshaped_w
        
        if isinstance(neuron_assign_list, list) is False:
            raise TypeError()

        if isinstance(activating_function_list, list) is False:
            raise TypeError()

        if isinstance(approximate_interface_list, list) is False:
            raise TypeError()

        if len(neuron_assign_list) == 0:
            v_n = (self.__reshaped_w - 2) ** 2
            neuron_assign_list = [v_n, v_n-1, v_n-2]

        if len(activating_function_list) == 0:
            # Default setting objects for activation function.
            activating_function_list = [
                LogisticFunction(binary_flag=True), 
                LogisticFunction(binary_flag=True), 
                LogisticFunction(binary_flag=True)
            ]

        if len(approximate_interface_list) == 0:
            # Default setting the object for function approximation.
            approximate_interface_list = [
                ShapeBMCD(v_h_flag=True, overlap_n=overlap_n), 
                ShapeBMCD(v_h_flag=False, overlap_n=overlap_n)
            ]

        super().__init__(
            dbm_builder,
            neuron_assign_list,
            activating_function_list,
            approximate_interface_list,
            learning_rate,
            dropout_rate,
            inferencing_flag=True,
            inferencing_plan="each"
        )

    def learn(
        self,
        np.ndarray[DOUBLE_t, ndim=2] observed_data_arr,
        int traning_count=1000,
        int batch_size=200,
        int r_batch_size=-1,
        sgd_flag=False
    ):
        '''
        Learning.

        Args:
            observed_data_arr:    The `np.ndarray` of observed data points.
            traning_count:        Training counts.
            batch_size:           Batch size.
            r_batch_size:         Batch size.
                                  If this value is `0`, the inferencing is a recursive learning.
                                  If this value is more than `0`, the inferencing is a mini-batch recursive learning.
                                  If this value is '-1', the inferencing is not a recursive learning.
            sgd_flag:             Learning with the stochastic gradient descent(SGD) or not.
        '''
        cdef np.ndarray[DOUBLE_t, ndim=2] init_observed_data_arr = observed_data_arr.copy()

        observed_data_arr = self.__reshape_observed_data(observed_data_arr)

        cdef int row_y = observed_data_arr.shape[0]
        cdef int col_x = observed_data_arr.shape[1]

        cdef int i
        cdef int row_i = observed_data_arr.shape[0]
        cdef int j
        cdef np.ndarray[DOUBLE_t, ndim=1] data_arr
        cdef np.ndarray[DOUBLE_t, ndim=1] feature_point_arr
        cdef int sgd_key

        inferenced_data_list = [None] * row_i
        for k in range(traning_count):
            for i in range(row_i):
                if sgd_flag is True:
                    sgd_key = np.random.randint(row_i)
                    data_arr = observed_data_arr[sgd_key]
                else:
                    data_arr = observed_data_arr[i].copy()

                for j in range(len(self.rbm_list)):
                    self.rbm_list[j].approximate_learning(
                        data_arr,
                        1,
                        batch_size
                    )
                    feature_point_arr = self.get_feature_point(j)
                    data_arr = feature_point_arr

                rbm_list = self.rbm_list[::-1]
                for j in range(len(rbm_list)):
                    data_arr = self.get_feature_point(len(rbm_list)-1-j)
                    rbm_list[j].approximate_inferencing(
                        data_arr,
                        1,
                        r_batch_size
                    )
                if k == traning_count - 1:
                    inferenced_data_list[i] = rbm_list[-1].graph.visible_activity_arr
        self.__visible_points_arr = np.array(inferenced_data_list)
        self.__visible_points_arr = self.__reshape_inferenced_data(init_observed_data_arr, self.__visible_points_arr)

    def __reshape_observed_data(self, np.ndarray[DOUBLE_t, ndim=2] observed_data_arr):
        '''
        Reshape `np.ndarray` of observed data ponints for Shape-BM.
        
        Args:
            observed_data_arr:    The `np.ndarray` of observed data points.

        Returns:
            np.ndarray[DOUBLE_t, ndim=2] observed data points
        '''

        cdef int row_y = observed_data_arr.shape[0]
        cdef int col_x = observed_data_arr.shape[1]

        feature_arr_list = []

        cdef int unit_n = int(self.__reshaped_w / 2)
        unit_arr = np.array(list(range(unit_n)))
        length_list = np.r_[
            unit_arr.copy()[::-1] * -1,
            unit_arr[1:]
        ].tolist()

        v_list_list = []
        for x in range(col_x):
            for y in range(row_y):
                v_list = []
                for x_add in length_list:
                    for y_add in length_list:
                        try:
                            v_list.append(observed_data_arr[y+y_add, x+x_add])
                        except IndexError:
                            v_list.append(0)
                v_list_list.append(v_list)
        cdef np.ndarray[DOUBLE_t, ndim=2] reshape_arr = np.array(v_list_list).astype(np.float64)
        return reshape_arr

    def __reshape_inferenced_data(
        self, 
        np.ndarray[DOUBLE_t, ndim=2] observed_data_arr, 
        np.ndarray[DOUBLE_t, ndim=2] inferenced_data_arr
    ):
        '''
        Reshape `np.ndarray` of inferenced data ponints for Shape-BM.
        
        Args:
            observed_data_arr:    The `np.ndarray` of observed data points.
            inferenced_data_arr:  The `np.ndarray` of inferenced data points.

        Returns:
            np.ndarray[DOUBLE_t, ndim=2] inferenced data points
        '''
        cdef int center_i = int(inferenced_data_arr.shape[1]/2)+1
        cdef np.ndarray[DOUBLE_t, ndim=1] shaped_data_arr = inferenced_data_arr[:, center_i]

        cdef int row_y = observed_data_arr.shape[0]
        cdef int col_x = observed_data_arr.shape[1]

        cdef np.ndarray[DOUBLE_t, ndim=2] reshape_arr = observed_data_arr.copy()

        i = 0
        for x in range(col_x):
            for y in range(row_y):
                reshape_arr[y, x] = reshape_arr[y, x] * shaped_data_arr[i]
                i += 1

        if reshape_arr.min() != 0 or reshape_arr.max() != 1:
            reshape_arr = 255 * (reshape_arr - reshape_arr.min()) / (reshape_arr.max() - reshape_arr.min())
        return reshape_arr
