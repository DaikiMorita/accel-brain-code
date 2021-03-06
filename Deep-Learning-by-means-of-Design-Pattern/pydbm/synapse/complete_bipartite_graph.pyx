# -*- coding: utf-8 -*-
import numpy as np
cimport numpy as np
cimport cython
from pydbm.synapse_list import Synapse
from pydbm.activation.interface.activating_function_interface import ActivatingFunctionInterface


class CompleteBipartiteGraph(Synapse):
    '''
    Complete Bipartite Graph.
    
    The shallower layer is to the deeper layer what the visible layer is to the hidden layer.
    '''
    # Activity of neuron in visible layer.
    __visible_activity_arr = np.array([])

    def get_visible_activity_arr(self):
        ''' getter '''
        if isinstance(self.__visible_activity_arr, np.ndarray) is False:
            raise TypeError("The type of __visible_activity_arr must be `np.ndarray`.")

        return self.__visible_activity_arr

    def set_visible_activity_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __visible_activity_arr must be `np.ndarray`.")

        self.__visible_activity_arr = value

    visible_activity_arr = property(get_visible_activity_arr, set_visible_activity_arr)

    # Activity of neuron in hidden layer.
    __hidden_activity_arr = np.array([])

    def get_hidden_activity_arr(self):
        ''' getter '''
        if isinstance(self.__hidden_activity_arr, np.ndarray) is False:
            raise TypeError("The type of __hidden_activity_arr must be `np.ndarray`.")
        return self.__hidden_activity_arr

    def set_hidden_activity_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __hidden_activity_arr must be `np.ndarray`.")
        self.__hidden_activity_arr = value

    hidden_activity_arr = property(get_hidden_activity_arr, set_hidden_activity_arr)

    # Bias of neuron in visible layer.
    __visible_bias_arr = np.array([])

    def get_visible_bias_arr(self):
        ''' getter '''
        if isinstance(self.__visible_bias_arr, np.ndarray) is False:
            raise TypeError("The type of __visible_bias_arr must be `np.ndarray`.")

        return self.__visible_bias_arr

    def set_visible_bias_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __visible_bias_arr must be `np.ndarray`.")

        self.__visible_bias_arr = value

    visible_bias_arr = property(get_visible_bias_arr, set_visible_bias_arr)

    # Bias of neuron in hidden layer.
    __hidden_bias_arr = np.array([])

    def get_hidden_bias_arr(self):
        ''' getter '''
        if isinstance(self.__hidden_bias_arr, np.ndarray) is False:
            raise TypeError("The type of __hidden_bias_arr must be `np.ndarray`.")

        return self.__hidden_bias_arr

    def set_hidden_bias_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __hidden_bias_arr must be `np.ndarray`.")

        self.__hidden_bias_arr = value

    hidden_bias_arr = property(get_hidden_bias_arr, set_hidden_bias_arr)

    # Diff of Bias of neuron in visible layer.
    __visible_diff_bias_arr = np.array([])

    def get_visible_diff_bias_arr(self):
        ''' getter '''
        if isinstance(self.__visible_diff_bias_arr, np.ndarray) is False:
            raise TypeError("The type of __visible_diff_bias_arr must be `np.ndarray`.")

        return self.__visible_diff_bias_arr

    def set_visible_diff_bias_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __visible_diff_bias_arr must be `np.ndarray`.")

        self.__visible_diff_bias_arr = value

    visible_diff_bias_arr = property(get_visible_diff_bias_arr, set_visible_diff_bias_arr)

    # Diff of Bias of neuron in hidden layer.
    __hidden_diff_bias_arr = np.array([])

    def get_hidden_diff_bias_arr(self):
        ''' getter '''
        if isinstance(self.__hidden_diff_bias_arr, np.ndarray) is False:
            raise TypeError("The type of __hidden_diff_bias_arr must be `np.ndarray`.")

        return self.__hidden_diff_bias_arr

    def set_hidden_diff_bias_arr(self, value):
        ''' setter '''
        if isinstance(value, np.ndarray) is False:
            raise TypeError("The type of __hidden_diff_bias_arr must be `np.ndarray`.")

        self.__hidden_diff_bias_arr = value

    hidden_diff_bias_arr = property(get_hidden_diff_bias_arr, set_hidden_diff_bias_arr)

    # Activation function in visible layer.
    def get_visible_activating_function(self):
        ''' getter '''
        if isinstance(self.shallower_activating_function, ActivatingFunctionInterface) is False:
            raise TypeError("The type of __visible_activating_function must be `ActivatingFunctionInterface`.")
        return self.shallower_activating_function

    def set_visible_activating_function(self, value):
        ''' setter '''
        if isinstance(value, ActivatingFunctionInterface) is False:
            raise TypeError("The type of __visible_activating_function must be `ActivatingFunctionInterface`.")
        self.shallower_activating_function = value

    visible_activating_function = property(get_visible_activating_function, set_visible_activating_function)

    # Activation function in hidden layer.
    def get_hidden_activating_function(self):
        ''' getter '''
        if isinstance(self.deeper_activating_function, ActivatingFunctionInterface) is False:
            raise TypeError("The type of __hidden_activating_function must be `ActivatingFunctionInterface`.")
        return self.deeper_activating_function

    def set_hidden_activating_function(self, value):
        ''' setter '''
        if isinstance(value, ActivatingFunctionInterface) is False:
            raise TypeError("The type of __hidden_activating_function must be `ActivatingFunctionInterface`.")
        self.deeper_activating_function = value

    hidden_activating_function = property(get_hidden_activating_function, set_hidden_activating_function)

    def create_node(
        self,
        int shallower_neuron_count,
        int deeper_neuron_count,
        shallower_activating_function,
        deeper_activating_function,
        np.ndarray weights_arr=np.array([])
    ):
        '''
        Set links of nodes to the graphs.

        Override.

        Args:
            shallower_neuron_count:             The number of neurons in shallower layer.
            deeper_neuron_count:                The number of neurons in deeper layer.
            shallower_activating_function:      The activation function in shallower layer.
            deeper_activating_function:         The activation function in deeper layer.
            weights_arr:                        The weights of links.
        '''
        self.visible_bias_arr = np.random.uniform(low=0, high=1, size=(shallower_neuron_count, ))
        self.hidden_bias_arr = np.random.uniform(low=0, high=1, size=(deeper_neuron_count, ))
        self.visible_diff_bias_arr = np.zeros(self.visible_bias_arr.shape)
        self.hidden_diff_bias_arr = np.zeros(self.hidden_bias_arr.shape)

        super().create_node(
            shallower_neuron_count,
            deeper_neuron_count,
            shallower_activating_function,
            deeper_activating_function,
            weights_arr
        )
