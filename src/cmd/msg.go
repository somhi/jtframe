/*  This file is part of JT_FRAME.
    JTFRAME program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JTFRAME program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JTFRAME.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Date: 28-8-20122 */

package cmd

import (
	"github.com/jotego/jtframe/msg"

	"github.com/spf13/cobra"
)

var msg_args msg.Args

var msgCmd = &cobra.Command{
	Use:   "msg <core-name>",
	Short: "Parses the core's msg file to generate a pause screen message",
	Long: `Parses the core's msg file in the config folder to generate a message. The message will be shown during the pause screen when the core is compiled with JTFRAME credits.
The lines cannot be longer than 32 characters.
There are four colours available: red, green, blue and white. Each line starts as white and the colour is changed by using a escape character and the colour first letter in capitals: \R for red, etc.
The msg file gets parsed into two files: msg.hex and msg.bin, placed in the current directory.
`,
	Run: func(cmd *cobra.Command, args []string) {
		msg_args.Core = args[0]

		msg.Run(msg_args)
	},
	Args: cobra.ExactArgs(1),
}

func init() {
	rootCmd.AddCommand(msgCmd)
}
