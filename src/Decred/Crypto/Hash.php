<?php namespace Decred\Crypto;

class Hash
{
    /**
     * @param string $data
     *
     * @return string
     */
    public static function blake($data)
    {
        if (extension_loaded('blake')) {
            return \Blake\Hash::blake256($data);
        }

        $state = new Blake\State256();
        $state->update($data);
        return $state->finalize();
    }
}
