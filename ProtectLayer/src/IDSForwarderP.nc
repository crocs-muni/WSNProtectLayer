module IDSForwarderP{
	uses {
		interface Receive;
		}
}
implementation{

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len){
		// TODO Forward msg
		return msg;
	}
}