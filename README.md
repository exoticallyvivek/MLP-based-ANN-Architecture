While the world races to build smarter AI models, I found myself asking a different question ,What if instead of just using AI, I built the hardware that runs it? While everyone around me was fine-tuning models and writing Python scripts, I took my passion for VLSI and chip design and tried to do what only top semiconductor companies do design AI hardware from the ground up. This summer, as part of my internship at Dhirubhai Ambani University under the guidance of Prof. Tapas Kumar Maiti, that question became a real chip design project.


In the starting of my BTech I still remember that I was still figuring out how to make a microcontroller blink an LED. This summer I designed and physically laid out a neural network accelerator chip entirely from scratch in 90nm CMOS, from mathematical equations all the way down to transistor-level silicon geometry.
The architecture. At the heart of this chip are two hardware-dedicated engines running concurrently , a forward propagation datapath and a backward propagation datapath. The forward engine computes weighted inputs across network layers and passes them through hardware activation function units. The backward engine computes error, propagates gradients layer by layer, and drives weight and bias update logic all in silicon, at clock speed.

The mathematical units. Every neuron computation involves custom adder trees, saturation arithmetic, fixed-point precision management and gradient accumulation logic. The activation function lives in a custom ROM-based lookup table a hand-designed memory block with the sigmoid curve encoded directly into the silicon bitcell array.


The gradient computation units. Building the backward pass physically means implementing delta computation units, derivative-of-activation blocks, gradient multiplier units and sign-based weight update accumulators all with precise pipeline delays ensuring data arrives at the right place at the right clock cycle.


What this taught me. When you implement a neural network in hardware rather than software, you stop thinking about loss curves and learning rates and start thinking about propagation delay, signal fanout, power rail distribution and physical timing constraints. You realize how much mathematical elegance has to survive contact with brutal physical reality before intelligence can actually run fast in silicon. Getting to go from algorithm all the way to physical layout and see it come together is something I'll carry for the rest of my career
Grateful to Prof. Tapas Kumar Maiti and Dhirubhai Ambani University for the opportunity. Would love to connect with anyone working at the intersection of AI and silicon.
