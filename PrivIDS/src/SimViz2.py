#!/usr/bin/python
#----------------------------------------------------------------------------
# SimViz visualizes the communication of the wireless sensor network. It can also
# generate network topology.
#
#----------------------------------------------------------------------------
# Copyright 2011, Petr Stepanek
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#----------------------------------------------------------------------------

import gobject
import pygtk
pygtk.require("2.0")
import gtk
import csv
import cairo
import pangocairo
import pango
from math import pi, hypot, sqrt, fabs
from random import randrange
from collections import deque

class Window:
    def __init__(self):
#        Inicialization of the main window
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("SimViz")
        self.window.set_position(gtk.WIN_POS_CENTER)
        self.window.set_size_request(12, 102)
        self.window.set_default_size(700, 600) #top menu is 90px height
        self.nodeSize = 10
        self.numberOfNodes = 0
        self.radius = 0
        self.topologyGenMethod = 1
        self.resizeRequest = False
        self.screen = None


#        Placing all the widgets
#       vBox
        self.vBox = gtk.VBox(False, 5)
#       hBox
        self.hBox = gtk.HBox(False, 0)
#       vBox1
        self.vBox1 = gtk.VBox(False, 4)
#       hBox1
        self.hBox1 = gtk.HBox(False, 5)
#        Canvas x lable
        self.canvasXLabel = gtk.Label("Canvas x:")
        self.hBox1.pack_start(self.canvasXLabel, False, True, 0)
        self.canvasXLabel.show()
#        Canvas x entry
        self.canvasXEntry = gtk.Entry(0)
        self.canvasXEntry.set_text("700")
        self.canvasXEntry.set_width_chars(5)
        self.hBox1.pack_start(self.canvasXEntry, False, True, 0)
        self.canvasXEntry.show()
#        Canvas y label
        self.canvasYLabel = gtk.Label("y:")
        self.hBox1.pack_start(self.canvasYLabel, False, True, 0)
        self.canvasYLabel.show()
#        Canvas y entry
        self.canvasYEntry = gtk.Entry(0)
        self.canvasYEntry.set_text("510")
        self.canvasYEntry.set_width_chars(4)
        self.hBox1.pack_start(self.canvasYEntry, False, True, 0)
        self.canvasYEntry.show()
#        Separator 1
        self.separator1 = gtk.VSeparator()
        self.hBox1.pack_start(self.separator1, False, True, 0)
        self.separator1.show()
#        Number lable
        self.numberLabel = gtk.Label("Nodes:")
        self.hBox1.pack_start(self.numberLabel, False, True, 0)
        self.numberLabel.show()
#        Number entry
        self.numberEntry = gtk.Entry(4)
        self.numberEntry.set_text("20")
        self.numberEntry.set_width_chars(5)
        self.hBox1.pack_start(self.numberEntry, False, True, 0)
        self.numberEntry.show()
#        Separator 2
        self.separator2 = gtk.VSeparator()
        self.hBox1.pack_start(self.separator2, False, True, 0)
        self.separator2.show()
#        Radius entry
        self.radiusLabel = gtk.Label("Radius:")
        self.hBox1.pack_start(self.radiusLabel, False, True, 0)
        self.radiusLabel.show()
        self.radiusEntry = gtk.Entry(4)
        self.radiusEntry.set_text("200")
        self.radiusEntry.set_width_chars(4)
        self.hBox1.pack_start(self.radiusEntry, False, True, 0)
        self.radiusEntry.show()
#        Separator 3
        self.separator3 = gtk.VSeparator()
        self.hBox1.pack_start(self.separator3, False, True, 0)
        self.separator3.show()
#        NeighboursLimit label
        self.neighboursLimitLabel = gtk.Label("Max neighbours:")
        self.hBox1.pack_start(self.neighboursLimitLabel, False, True, 0)
#        NeighboursLimit entry
        self.neighboursLimitEntry = gtk.Entry(0)
        self.neighboursLimitEntry.set_text("8")
        self.neighboursLimitEntry.set_width_chars(2)
        self.hBox1.pack_start(self.neighboursLimitEntry, False, True, 0)
#        Grid label
        self.gridLabel = gtk.Label("Grid proportions:")
        self.hBox1.pack_start(self.gridLabel, False, True, 0)

        self.vBox1.pack_start(self.hBox1, False, True, 0)
        self.hBox1.show()
#       /hBox1

#       hBox2
        self.hBox2 = gtk.HBox(False, 2)
#        Load button
        self.openButton = gtk.Button("Load topology")
        self.hBox2.pack_start(self.openButton, False, True, 0)
        self.openButton.show()
#        Save button
        self.writeButton = gtk.Button("Save topology")
        self.hBox2.pack_start(self.writeButton, False, True, 0)
        self.writeButton.show()
#        Log button
        self.openLogButton = gtk.Button("Open log")
        self.hBox2.pack_start(self.openLogButton, False, True, 0)
        self.openLogButton.show()
#        Radius checkButton
        self.showRadius = gtk.CheckButton("Radius")
        self.showRadius.set_active(True)
        self.hBox2.pack_start(self.showRadius, True, True, 0)
        self.showRadius.show()
#        Grid x label
        self.gridXLabel = gtk.Label("x:")
        self.hBox2.pack_start(self.gridXLabel, False, True, 0)
#        Grid x entry
        self.gridXEntry = gtk.Entry(0)
        self.gridXEntry.set_text("10")
        self.gridXEntry.set_width_chars(3)
        self.hBox2.pack_start(self.gridXEntry, False, True, 5)
#        Grid y label
        self.gridYLabel = gtk.Label("y:")
        self.hBox2.pack_start(self.gridYLabel, False, True, 0)
#        Grid y entry
        self.gridYEntry = gtk.Entry(0)
        self.gridYEntry.set_text("1")
        self.gridYEntry.set_width_chars(3)
        self.hBox2.pack_start(self.gridYEntry, False, True, 5)
        self.vBox1.pack_start(self.hBox2, False, True, 0)
        self.hBox2.show()
#       /hBox2

#       hBox3
        self.hBox3 = gtk.HBox(False, 2)
#        Play button
        self.playButton = gtk.Button("Play")
        self.playButton.set_sensitive(False)
        self.hBox3.pack_start(self.playButton, False, True, 0)
        self.playButton.show()
#        Pause button
        self.pauseButton = gtk.Button("Pause")
        self.pauseButton.set_sensitive(False)
        self.hBox3.pack_start(self.pauseButton, False, True, 0)
        self.pauseButton.show()
#        Step button
        self.stepButton = gtk.Button("Step")
        self.stepButton.set_sensitive(False)
        self.hBox3.pack_start(self.stepButton, False, True, 0)
        self.stepButton.show()
#        Speed combo
        self.listStore = gtk.ListStore(gobject.TYPE_STRING)
        self.speedCombo = gtk.combo_box_new_text()
        self.speedCombo.append_text("70ms")
        self.speedCombo.append_text("500ms")
        self.speedCombo.append_text("1000ms")
        self.speedCombo.append_text("1500ms")
        self.speedCombo.set_active(1)
        self.hBox3.pack_start(self.speedCombo, False, True, 0)
        self.speedCombo.show()
#        Separator 4
        self.separator4 = gtk.VSeparator()
        self.hBox3.pack_start(self.separator4, False, True, 10)
        self.separator4.show()
#        Generate button
        self.genButton = gtk.Button("Generate topology")
        self.hBox3.pack_start(self.genButton, False, True, 0)
        self.genButton.show()
        self.vBox1.pack_start(self.hBox3, False, True, 0)
        self.hBox3.show()
#       /hBox3

        self.hBox.pack_start(self.vBox1, False, True, 0)
        self.vBox1.show()
#       /vBox1

#       vBox4
        self.vBox4 = gtk.VBox(False, 0)

#        Random radioButton
        self.randomRadioButton = gtk.RadioButton(None, "Random")
        self.vBox4.pack_start(self.randomRadioButton, False, True, 0)
        self.randomRadioButton.show()
#        Max radioButton
        self.maxRadioButton = gtk.RadioButton(self.randomRadioButton, "Max")
        self.vBox4.pack_start(self.maxRadioButton, False, True, 0)
        self.maxRadioButton.show()
#        Coherent radioButton3
        self.coherentRadioButton = gtk.RadioButton(self.randomRadioButton, "Coherent")
        self.vBox4.pack_start(self.coherentRadioButton, False, True, 0)
        self.coherentRadioButton.show()
        self.hBox.pack_start(self.vBox4, False, True, 0)
        self.vBox4.show()
#        Grid radioButton
        self.gridRadioButton = gtk.RadioButton(self.randomRadioButton, "Grid")
        self.vBox4.pack_start(self.gridRadioButton, False, True, 0)
        self.gridRadioButton.show()
#       /vBox4

        self.vBox.pack_start(self.hBox, False, True, 0)
        self.hBox.show()
#       /hBox

#        Screen
        self.screen = Screen()
        self.vBox.pack_start(self.screen, True, True, 0)
        self.screen.show()

        self.window.add(self.vBox)
        self.vBox.show()
#       /vBox

        self.window.show()

#        Connecting window with functions
        self.window.connect("destroy", gtk.main_quit)
        self.window.connect("configure-event", self.showSize)
        self.window.connect("button-press-event", self.screen.showNodeInfo)
#        Connecting buttons with functions
        self.genButton.connect("clicked", self.generate, None)
        self.writeButton.connect("clicked", self.screen.writeTopology, None)
        self.openLogButton.connect("clicked", self.openTossimLog, None)
        self.playButton.connect("clicked", self.screen.playTossimLog, None)
        self.pauseButton.connect("clicked", self.screen.pauseTossimLog, None)
        self.stepButton.connect("clicked", self.screen.stepTossimLog, None)
        self.openButton.connect("clicked", self.openTopology, None)
#        self.openButton.connect("clicked", self.screen.readTopology, "/home/pete/NetBeansProjects/SimViz/src/files/test2.txt")
        self.showRadius.connect("toggled", self.setShowRadius, None)
#        Connecting radioButtons with functions
        self.randomRadioButton.connect("toggled", self.setMethod, 1)
        self.maxRadioButton.connect("toggled", self.setMethod, 2)
        self.coherentRadioButton.connect("toggled", self.setMethod, 3)
        self.gridRadioButton.connect("toggled", self.setMethod, 4)

        self.speedCombo.connect("changed", self.setSpeed, None)

    def main(self):
        gtk.main()

#    This method sets speed of visualisation.
    def setSpeed(self, widget, data):
        try:
            model = self.speedCombo.get_model()
            active = self.speedCombo.get_active_iter()
            if active < 0:
                self.screen.speed = 400
            else:
                self.screen.speed = int(model[active][0].rstrip("ms"))
        except Exception, e:
            print e

#    This method generates topology.
    def generate(self, widget, data):
#        Erasing all data from previous animation.
        self.screen.com = False
        self.screen.nodesMemory = {}

        try:
            generation = True
            self.canvasWidth = int(self.canvasXEntry.get_text())
            self.canvasHeight = int(self.canvasYEntry.get_text())
            self.windowWidth = int(self.canvasXEntry.get_text()) + self.screen.area.x
            self.windowHeight = int(self.canvasYEntry.get_text()) + self.screen.area.y
            self.window.resize(self.windowWidth, self.windowHeight)
            self.numberOfNodes = int(self.numberEntry.get_text())
            self.radius = int(self.radiusEntry.get_text())

            self.screen.setParameters(self.radius)
            self.finalNodeList = []

            self.screen.currentDrawMethod = self.screen.drawGenerating
            self.screen.window.invalidate_rect((0,0,self.screen.area.width,self.screen.area.height),False)
            gtk.gdk.window_process_all_updates()

#            Random generation
            if self.topologyGenMethod == 1:
                self.nodeList = []
                linkLayerGenerateTopology = open("topology.out", "r")
                topology = linkLayerGenerateTopology.read()
                row = topology.split("\n")
                for i in row:
                    fields = i.split("\t")
                    if len(fields) == 3:
                        x = int(round(float(fields[1])*2,0)) 
                        y = int(round(float(fields[2])*2,0))
                                       
                    if not self.nodeList.count((x,y)):
                        self.nodeList.append((x, y))
                        for i in range(0, len(self.nodeList)):
                            x1, y1 = self.nodeList[i]
        #                   Choosing nodes which can hear eachother
                            if hypot(x1 - x, y1 - y) < self.screen.radius:
                                neighboursSet = [(x, y)]
                                neighboursSet.append((x1, y1))
                                self.finalNodeList.append(neighboursSet)
		
		linkLayerGenerateTopology.close() 

#            Random max neighbours
            elif self.topologyGenMethod == 2:
                self.nodeList = []
                self.maxNeighbours = int(self.neighboursLimitEntry.get_text())
                maxGeneration = 0

                while len(self.nodeList) < self.numberOfNodes:
                    self.breakCall = False
#                    When there is no node genrated neither for the 50000 times,
#                    process will end
                    print maxGeneration
                    if maxGeneration > 50000:
                            generation = False
                            break
                    x = randrange(1, self.canvasWidth - self.nodeSize)
                    y = randrange(1, self.canvasHeight - self.nodeSize)
                    n = 0
                    for node in self.nodeList:
                        if (node[0] == x) and (node[1] == y):
                            self.breakCall = True
                            break
                    if not self.breakCall:
                        self.nodeList.append((x, y, n))
                        self.neighbourList = []
                        maxGeneration += 1

#                        Number of neighbours is checked here. If the new node or
#                        any other node have more neighbours then the value
#                        of maxNeighbours then the new node is erased.
#                        Otherwise new neighbourList with all neighbours
#                        is created.
                        for i in range(0, len(self.nodeList)):
                            x1, y1, n1 = self.nodeList[i]
                            if ((x, y, n) != self.nodeList[i]):
            #                   Choosing nodes which can hear eachother
                                if hypot(x1 - x, y1 - y) < self.screen.radius:
                                    if n1 < self.maxNeighbours:
                                        if len(self.neighbourList) < self.maxNeighbours:
                                            self.neighbourList.append((x1, y1, n1))
                                        else:
                                            self.neighbourList = []
                                            self.nodeList.pop()
                                            self.breakCall = True
                                            break
                                    else:
                                        self.neighbourList = []
                                        self.nodeList.pop()
                                        self.breakCall = True
                                        break
                            else:
                                self.finalNodeList.append([(x, y), (x, y)])

#                        If the new node has less or equal number of neighbours,
#                        it is added to the neighbourList and all his neighbours
#                        will add 1 to the number of theirs neighbours.
                        if not self.breakCall:
                            maxGeneration = 0
                            for node in self.neighbourList:
                                index = self.nodeList.index(node)

                                x1, y1, n1 = node
                                n1 +=1
                                self.nodeList.pop(index)
                                self.nodeList.insert(index, (x1, y1, n1))

                                tempNeighboursList = [(x, y)]
                                tempNeighboursList.append((x1, y1))
                                self.finalNodeList.append(tempNeighboursList)

                                n = len(self.neighbourList)
                                self.nodeList.pop()
                                self.nodeList.append((x, y, n))

                        if maxGeneration > 600000:
                            generation = False
                            break

#            Generating of the coherent map
            elif self.topologyGenMethod == 3:
                x = randrange(1, self.canvasWidth - self.nodeSize)
                y = randrange(1, self.canvasHeight - self.nodeSize)
                self.nodeList = [(x, y)]

                while len(self.nodeList) < self.numberOfNodes:
                    node = self.nodeList[randrange(len(self.nodeList))]
                    x0, y0 = node
                    x0 += self.nodeSize / 2
                    y0 += self.nodeSize / 2

#                    Generating of the x coordinates of the neighbour
                    if (self.screen.radius - 1) > x0: #if True, the node radio touches the left border
                        if (x0 + self.screen.radius) > self.canvasWidth: #if True, the node radio touches the right border
                            x = randrange(self.nodeSize / 2, self.canvasWidth - (self.nodeSize / 2)) #the node radio touches left and right border
                        else:
                            x = randrange((self.nodeSize / 2) + 1, x0 + self.screen.radius - 1) #the node radio touches only the left border
                    else: #the node radio doesnt touch the left border
                        if (x0 + self.screen.radius) > self.canvasWidth: #if True, the node radio touches only the right border
                            x = randrange(x0 - self.screen.radius + 1, self.canvasWidth - (self.nodeSize / 2)) #the node radio touches only the right border
                        else:
                            x = randrange(x0 - self.screen.radius + 1, x0 + self.screen.radius - 1) #the node radio doesnt touch any border

#                    Generating of the y coordinates of the neighbour
                    deltaY = round(sqrt(fabs((self.screen.radius * self.screen.radius) - ((x - x0) * (x - x0)))))

                    if (y0 - deltaY) < ((self.nodeSize / 2) + 1): # obdelnik je nad canvasem
                        if (y0 + deltaY) > (self.canvasHeight - (self.nodeSize / 2) - 1): # obdelnik je pod canvasem
                            y = randrange((self.nodeSize / 2) + 1, self.canvasHeight - (self.nodeSize / 2)) # Nahore i dole
                        else:
                            y = randrange((self.nodeSize / 2) + 1, y0 + deltaY) # obdelnik je jen nad canvasem
                    else:
                        if (y0 + deltaY) > (self.canvasHeight - (self.nodeSize / 2) - 1): # obdelnik je pod canvasem
                            y = randrange(y0 - deltaY + 1, self.canvasHeight - (self.nodeSize / 2)) # Jen dole
                        else: # ani nad ani pod
                            y = randrange(y0 - deltaY + 1, y0 + deltaY) # Ani nad ani pod

                    x -= self.nodeSize / 2
                    y -= self.nodeSize / 2

                    if not self.nodeList.count((x,y)):
                        self.nodeList.append((x, y))

                        for i in range(0, len(self.nodeList) - 1):
                            x1, y1 = self.nodeList[i]
        #                   Choosing nodes which can hear eachother
                            if hypot(x1 - x, y1 - y) < self.screen.radius:
                                neighboursList = [(x, y)]
                                neighboursList.append((x1, y1))
                                self.finalNodeList.append(neighboursList)

#            Grid generation
            if self.topologyGenMethod == 4:
                self.nodeList = []
                self.numberOfXNodes = int(self.gridXEntry.get_text())
                self.numberOfYNodes = int(self.gridYEntry.get_text())
                self.xSpace = (self.canvasWidth - (self.numberOfXNodes*self.nodeSize + 2)) / (self.numberOfXNodes + 1)
                self.ySpace = (self.canvasHeight - (self.numberOfYNodes*self.nodeSize + 2)) / (self.numberOfYNodes + 1)

                if self.numberOfXNodes == 1:
                    self.minRadius = self.ySpace + self.nodeSize + 3
                    if self.radius < self.minRadius:
                        self.radiusEntry.set_text(str(self.minRadius))
                        self.screen.setParameters(self.minRadius)
                elif self.numberOfYNodes == 1:
                    self.minRadius = self.xSpace + self.nodeSize + 3
                    if self.radius < self.minRadius:
                        self.radiusEntry.set_text(str(self.minRadius))
                        self.screen.setParameters(self.minRadius)
                elif self.radius < max(self.xSpace + self.nodeSize + 3, self.ySpace + self.nodeSize + 3):
                    self.radiusEntry.set_text(str(max(self.xSpace + self.nodeSize + 3, self.ySpace + self.nodeSize + 3)))
                    self.screen.setParameters(max(self.xSpace + self.nodeSize + 3, self.ySpace + self.nodeSize + 3))

                x = 0
                for i in range(0, self.numberOfXNodes):
                    if i == 0:
                        x = x + self.xSpace
                    else:
                        x = x + self.xSpace + self.nodeSize + 2
                    y = 0
                    for j in range(0, self.numberOfYNodes):
                        if j == 0:
                            y = y + self.ySpace
                        else:
                            y = y + self.ySpace + self.nodeSize + 2
                        self.nodeList.append((x, y))

#                        Choosing nodes which can hear eachother
                        for k in range(0, len(self.nodeList)):
                            x1, y1 = self.nodeList[k]
                            if hypot(x1 - x, y1 - y) < self.screen.radius:
                                neighboursSet = [(x, y)]
                                neighboursSet.append((x1, y1))
                                self.finalNodeList.append(neighboursSet)

            if generation:
                self.screen.setList(self.finalNodeList)
            else:
                self.screen.currentDrawMethod = self.screen.drawError
                self.screen.window.invalidate_rect((0,0,self.screen.area.width,self.screen.area.height),False)

        except ValueError, e:
            print e
            md = gtk.MessageDialog(self.window,
            gtk.DIALOG_DESTROY_WITH_PARENT, gtk.MESSAGE_ERROR,
            gtk.BUTTONS_CLOSE, "Error")
            md.run()
            md.destroy()

#    This method sets if the radio should be shown and redraw the canvas.
    def setShowRadius(self, checkbutton, data):
        self.screen.showRadius = checkbutton.get_active()
        self.screen.currentDrawMethod = self.screen.drawAll
        self.screen.window.invalidate_rect((0,0,self.screen.area.width,self.screen.area.height),False)

#    This method writes the size of the canvas with each resizing. It also
#    resize window after setting proportions in Entrys.
    def showSize(self, widget, event):
        try:
            if self.screen.baseSurface != None:
                self.canvasXEntry.set_text(str(self.window.get_size()[0] - self.screen.area.x))
                self.canvasYEntry.set_text(str(self.window.get_size()[1] - self.screen.area.y))
                self.screen.currentDrawMethod = self.screen.drawAll
#                Vykresluje jen cast okna...nee uplne cely pri zvetseni
                self.screen.window.invalidate_rect((0,0,self.screen.area.width,self.screen.area.height),False)
                self.screen.window.process_updates(False)
                if self.screen.boxVisible == True:
                    self.screen.update(self.screen.drawInfoBox)
        except Exception, e:
            print e

#    This method shows or hides neighboursLimitLabel, neighboursLimitEntry, gridLabel,
#    gridXLabel, gridYLabel, gridXEntry, gridYEntry and (un)sets numberEntry sensitive.
    def setMethod(self, widget, data):
        if data == 2:
            self.neighboursLimitLabel.show()
            self.neighboursLimitEntry.show()
            self.gridLabel.hide()
            self.gridXLabel.hide()
            self.gridYLabel.hide()
            self.gridXEntry.hide()
            self.gridYEntry.hide()
            self.numberEntry.set_sensitive(True)
        elif data == 4:
            self.gridLabel.show()
            self.gridXLabel.show()
            self.gridYLabel.show()
            self.gridXEntry.show()
            self.gridYEntry.show()
            self.neighboursLimitLabel.hide()
            self.neighboursLimitEntry.hide()
            self.numberEntry.set_sensitive(False)
        else:
            self.neighboursLimitLabel.hide()
            self.neighboursLimitEntry.hide()
            self.gridLabel.hide()
            self.gridXLabel.hide()
            self.gridYLabel.hide()
            self.gridXEntry.hide()
            self.gridYEntry.hide()
            self.numberEntry.set_sensitive(True)
        self.topologyGenMethod = data

#    This method opens topology file.
    def openTopology(self, widget, data):
        dialog = gtk.FileChooserDialog("Open topology", None, gtk.FILE_CHOOSER_ACTION_OPEN, (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OPEN, gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)
        dialog.set_current_folder("/home/pete/NetBeansProjects/SimViz/src/files/")

        filter = gtk.FileFilter()
        filter.set_name("TXT")
        filter.add_pattern("*.txt")
        dialog.add_filter(filter)

        filter = gtk.FileFilter()
        filter.set_name("All files")
        filter.add_pattern("*")
        dialog.add_filter(filter)

        response = dialog.run()
        if response == gtk.RESPONSE_OK:
            self.screen.readTopology(dialog.get_filename())
            self.nodeList = self.screen.nodeList
            self.numberOfNodes = self.screen.numberOfMotes
            self.radius = self.screen.radius
            self.numberEntry.set_text(str(self.numberOfNodes))
            self.radiusEntry.set_text(str(self.radius))
#            Erasing data from the previous animation
            self.screen.com = False
            self.screen.nodesMemory = {}
        dialog.destroy()

#    This method opens log file.
    def openTossimLog(self, widget, data):
        if self.screen.logOpend:
            self.screen.tossimLogFile.close()
        dialog = gtk.FileChooserDialog("Open log", None, gtk.FILE_CHOOSER_ACTION_OPEN, (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OPEN, gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)
        dialog.set_current_folder("/home/pete/NetBeansProjects/SimViz/src/files/")

        filter = gtk.FileFilter()
        filter.set_name("LOG")
        filter.add_pattern("*.log")
        dialog.add_filter(filter)

        filter = gtk.FileFilter()
        filter.set_name("All files")
        filter.add_pattern("*")
        dialog.add_filter(filter)

        response = dialog.run()
        if response == gtk.RESPONSE_OK:
            self.tossimLogFilename = dialog.get_filename()
            self.playButton.set_sensitive(True)
            self.stepButton.set_sensitive(True)
            self.pauseButton.set_sensitive(True)
            self.screen.setLogPath(self.tossimLogFilename)
#            Erasing data from the previous animation
            self.screen.com = False
            self.screen.nodesMemory = {}
            self.screen.update(self.screen.drawAll)
        dialog.destroy()
        """
#        tossimLogFilename = "/opt/tinyos-2.x/apps/Quido/packets.log"
        tossimLogFilename = "/home/pete/NetBeansProjects/SimViz/src/files/test2Collections.log"
        self.playButton.set_sensitive(True)
        self.stepButton.set_sensitive(True)
        self.pauseButton.set_sensitive(True)
        self.screen.setLogPath(tossimLogFilename)
#        Vymazani dat z redchozi animace
        self.screen.com = False
        self.screen.nodesMemory = {}
        self.screen.update(self.screen.drawAll)
        """

class Screen(gtk.DrawingArea):
    def __init__(self):
        super(Screen, self).__init__()
        self.connect("expose_event", self.expose)
        self.pangolayout = self.create_pango_layout("")
        self.add_events(gtk.gdk.BUTTON_PRESS_MASK)
        self.speed = 400
        """
        self.add_events(gtk.gdk.POINTER_MOTION_MASK |
                        gtk.gdk.POINTER_MOTION_HINT_MASK |
                        gtk.gdk.BUTTON_RELEASE_MASK |
                        gtk.gdk.BUTTON_PRESS_MASK)
        self.connect("button_press_event", self.showNodeInfo)
        self.connect("button_release_event", self.release)
        self.connect("motion_notify_event", self.showNodeInfo)
        """

        self.nodeList = []
        self.showRadius = True
        self.nodeSize = 10
        self.currentDrawMethod = self.drawAll
        self.comTuple = None
        self.baseSurface = None
        self.infoSurface = None
#        self.infoSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, 0, 0)
        self.row = []
        self.nodeX = -1
        self.nodeY = -1
        self.nodeWithBox = (-1, -1)
        self.possition = 0
        self.boxVisible = False
        self.tossimLogFile = None
        self.logOpend = False
        self.com = False
        self.nodesMemory = {}


    def expose(self, widget, event):
        print "expose"
        cr = widget.window.cairo_create()

#        set a clip region for the expose event
        cr.rectangle(event.area.x, event.area.y,
                     event.area.width, event.area.height)
        cr.clip()
        self.mainDraw(cr)
        return False

    """
    def myInvalidate(self):
        self.window.invalidate_rect((0,0,self.area.width,self.area.height),False)
        return False
    """

    def mainDraw(self, cr):
        self.area = self.get_allocation()
        print "Cairo (", self.area.x, self.area.y, self.area.width, self.area.height, ")"
        self.currentDrawMethod(cr)

#    This is the default drawing method which draws all layers and save them into baseSurface.
    def drawAll(self, cr):
        self.baseSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, self.area.width, self.area.height)
        crBase = cairo.Context(self.baseSurface)

        crBase.set_source_rgb(1.0, 1.0, 1.0)  #rgb / 255
        crBase.rectangle(0, 0, self.area.width, self.area.height)
        crBase.fill()

#        Extracting all nodes
        self.allNodesList = []
        for nodeTuple in self.nodeList:
            node0 = nodeTuple[0]
            node1 = nodeTuple[1]
            if not self.allNodesList.count(node0):
                self.allNodesList.append(node0)
            if not self.allNodesList.count(node1):
                self.allNodesList.append(node1)
        self.numberOfMotes = len(self.allNodesList)

#        Drawing communication areas
        if self.showRadius:
            for node in self.allNodesList:
                x, y = node
                crBase.set_source_rgba(0.24, 0.21, 1.0, 0.2)
                crBase.set_line_width(1.0)
                crBase.arc(x+5, y+5, self.radius, 0, 2 * pi)
                crBase.stroke()
            self.showRadius = True

#        Connecting nodes
        crBase.set_line_width(2.0)

        for nodeTuple in self.nodeList:
            node0 = nodeTuple[0]
            node1 = nodeTuple[1]
            x0, y0 = node1
            x1, y1 = node0

            if self.showRadius:
                crBase.set_source_rgba(0.0, 0.0, 0.0, 0.5)
            else:
                crBase.set_source_rgba(0.0, 0.0, 0.0, 0.2)
            crBase.move_to(x0+(self.nodeSize / 2), y0+(self.nodeSize / 2))
            crBase.line_to(x1+(self.nodeSize / 2), y1+(self.nodeSize / 2))
            crBase.stroke()

#        Draving nodes
        for node in self.allNodesList:
            x, y = node
            crBase.set_source_rgb(0, 0, 0)
            crBase.rectangle(x - 1, y - 1, self.nodeSize + 2, self.nodeSize + 2)
            crBase.fill()

            if node == self.nodeList[0][0]:
                crBase.set_source_rgb(0.8, 0, 0)
                crBase.rectangle(x, y, self.nodeSize, self.nodeSize)
                crBase.fill()
            else:
                crBase.set_source_rgb(0, 0.8, 0)
                crBase.rectangle(x, y, self.nodeSize, self.nodeSize)
                crBase.fill()
        cr.set_source_surface(self.baseSurface)
        cr.paint()
#        self.currentDrawMethod = self.redrawToBase

#    Redraw the canvas to the base surface.
    def redrawToBase(self, cr):
        cr.set_source_surface(self.baseSurface)
        cr.paint()
        if self.boxVisible == True:
            cr.set_source_surface(self.infoSurface)
            cr.paint()
        
#    This method draws the communication itself.
    def drawCommunicaton(self, cr):
        self.comSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, self.area.width, self.area.height)
        crCom = cairo.Context(self.comSurface)

#        Connecting nodes
        crCom.set_line_width(2.0)
        node0, node1 = self.comTuple
        x0, y0 = node0
        x1, y1 = node1

        if self.showRadius:
            crCom.set_source_rgb(1.0, 0.0, 0.0)
        else:
            crCom.set_source_rgb(1.0, 0.0, 0.0)
        crCom.move_to(x0+(self.nodeSize / 2), y0+(self.nodeSize / 2))
        crCom.line_to(x1+(self.nodeSize / 2), y1+(self.nodeSize / 2))
        crCom.stroke()

#        Draving the aim of communication
        x = x0 + 5 - (x0 - x1) / 4
        y = y0 + 5 - (y0 - y1) / 4
        crCom.arc(x, y, 5, 0, 2 * pi)
        crCom.fill()
        x = x0 + 5 - (x0 - x1) / 2
        y = y0 + 5 - (y0 - y1) / 2
        crCom.arc(x, y, 7, 0, 2* pi)
        crCom.fill()
        x = x0 + 5 - 3*(x0 - x1) / 4
        y = y0 + 5 - 3*(y0 - y1) / 4
        crCom.arc(x, y, 10, 0, 2 * pi)
        crCom.fill()

#        Draving nodes
        crCom.set_source_rgb(0, 0, 0)
        crCom.rectangle(x0 - 1, y0 - 1, self.nodeSize + 2, self.nodeSize + 2)
        crCom.rectangle(x1 - 1, y1 - 1, self.nodeSize + 2, self.nodeSize + 2)
        crCom.set_source_rgb(0, 0, 0.8)
        crCom.rectangle(x0, y0, self.nodeSize, self.nodeSize)
        crCom.rectangle(x1, y1, self.nodeSize, self.nodeSize)
        crCom.fill()

        cr.set_source_surface(self.baseSurface)
        cr.paint()
        cr.set_source_surface(self.comSurface)
        cr.paint()
        if self.boxVisible == True:
            cr.set_source_surface(self.infoSurface)
            cr.paint()

#    This method draws the information box about ongoing generation.
    def drawGenerating(self, cr):
        generatingSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, self.area.width, self.area.height)
        crGenerating = cairo.Context(generatingSurface)

#        Rounded rectangle
        crGenerating.set_source_rgb(0, 0.8, 0)
        crGenerating.set_line_width(10)
        crGenerating.arc(self.area.width/2 - 100, self.area.height/2 - 50, 10, 2 * (pi / 2), 3 * (pi / 2))
        crGenerating.arc(self.area.width/2 + 100, self.area.height/2 - 50, 10, 3 * (pi / 2), 4 * (pi / 2))
        crGenerating.arc(self.area.width/2 + 100, self.area.height/2 + 50, 10, 0 * (pi / 2), 1 * (pi / 2))  # ;o)
        crGenerating.arc(self.area.width/2 - 100, self.area.height/2 + 50, 10, 1 * (pi / 2), 2 * (pi / 2))
        crGenerating.close_path()
        crGenerating.stroke_preserve()

        crGenerating.set_source_rgb(1, 1, 1)
        crGenerating.fill()

        crGenerating.set_source_rgb(0, 0, 0)
        crGenerating.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        crGenerating.set_font_size(17)
        crGenerating.move_to(self.area.width/2 - 100, self.area.height/2 + 5)
        crGenerating.show_text("Please wait....generating")

        cr.set_source_surface(generatingSurface)
        cr.paint()

#    This method draws the information box about error during generation.
    def drawError(self, cr):
        generatingSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, self.area.width, self.area.height)
        crGenerating = cairo.Context(generatingSurface)

#        Rounded rectangle
        crGenerating.set_source_rgb(0, 0.8, 0)
        crGenerating.set_line_width(10)
        crGenerating.arc(self.area.width/2 - 120, self.area.height/2 - 60, 10, 2 * (pi / 2), 3 * (pi / 2))
        crGenerating.arc(self.area.width/2 + 120, self.area.height/2 - 60, 10, 3 * (pi / 2), 4 * (pi / 2))
        crGenerating.arc(self.area.width/2 + 120, self.area.height/2 + 60, 10, 0 * (pi / 2), 1 * (pi / 2))  # ;o)
        crGenerating.arc(self.area.width/2 - 120, self.area.height/2 + 60, 10, 1 * (pi / 2), 2 * (pi / 2))
        crGenerating.close_path()
        crGenerating.stroke_preserve()

        crGenerating.set_source_rgb(1, 1, 1)
        crGenerating.fill()

        crGenerating.set_source_rgb(0, 0, 0)
        crGenerating.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
        crGenerating.set_font_size(17)
        crGenerating.move_to(self.area.width/2 - 120, self.area.height/2 + 5)
        crGenerating.show_text("Error: bad chosen parameters")

        cr.set_source_surface(generatingSurface)
        cr.paint()

#        This method draws the information box with the nodes memory.
    def drawInfoBox(self, cr):
        self.infoSurface = cairo.ImageSurface(cairo.FORMAT_ARGB32, self.area.width, self.area.height)
        crInfo = cairo.Context(self.infoSurface)
        boxWidth = 500
        boxHeight = 230

        ###################################
        #           pango layout          #
        ###################################
        pg = pangocairo.CairoContext(crInfo)
        attr = pango.AttrList()
        fg_color = pango.AttrForeground(1, 1, 1, 0, -1)
        attr.insert(fg_color)

        layout = pg.create_layout()
        layout.set_width(pango.SCALE * (boxWidth - 4))
        layout.set_spacing(pango.SCALE * 3)
        layout.set_alignment(pango.ALIGN_LEFT)
        layout.set_font_description(pango.FontDescription("Arial 9"))
        layout.set_attributes(attr)
#        layout.set_wrap(PANGO_WRAP_WORD_CHAR)
#        layout.set_text("aaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaa ")

        ###################################

        if (self.nodeX + self.nodeSize + 1 + boxWidth) > self.area.width: # overreach on the right side
            if (self.nodeY - 1 - boxHeight) < 0: # overreach on the upper side
#                Box with dark header    #overreach on the right and upper side
                crInfo.set_source_rgba(0.8, 0.8, 0.8, 0.8)
                crInfo.rectangle(self.nodeX - 1 - boxWidth, self.nodeY + self.nodeSize + 1, boxWidth, boxHeight)
                crInfo.fill()
                crInfo.set_source_rgba(0.5, 0.5, 0.5, 0.5)
                crInfo.rectangle(self.nodeX - 1 - boxWidth, self.nodeY + self.nodeSize + 1, boxWidth, 16)
                crInfo.fill()

#                Pango text
                if self.nodeBoxId in self.nodesMemory:
                    messagesSet = self.nodesMemory[self.nodeBoxId]
                    move = 0
                    for i in range(len(messagesSet)-1, -1, -1):
                        crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY + self.nodeSize + 1 + 14 + move)
                        layout.set_text(messagesSet[i])
                        move += 11
                        pg.show_layout(layout)
                else:
                    fg_color = pango.AttrForeground(55000, 0, 0, 0, -1)
                    attr.insert(fg_color)
                    layout.set_alignment(pango.ALIGN_CENTER)
                    layout.set_font_description(pango.FontDescription("Arial Bold 10"))
                    crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY + self.nodeSize + (boxHeight)/2 - 5)
                    layout.set_text("Empty")
                    pg.show_layout(layout)

#                Headline
                crInfo.set_source_rgb(1, 1, 1)
                crInfo.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                crInfo.set_font_size(13)
                crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY + self.nodeSize + 1 +13)
                crInfo.show_text("Node {0}".format(self.nodeBoxId))
            else:
#                Box with dark header    #overreach on the right side
                crInfo.set_source_rgba(0.8, 0.8, 0.8, 0.8)
                crInfo.rectangle(self.nodeX - 1 - boxWidth, self.nodeY - boxHeight - 1, boxWidth, boxHeight)
                crInfo.fill()
                crInfo.set_source_rgba(0.5, 0.5, 0.5, 0.5)
                crInfo.rectangle(self.nodeX - 1 - boxWidth, self.nodeY - boxHeight - 1, boxWidth, 16)
                crInfo.fill()

#                Pango text
                if self.nodeBoxId in self.nodesMemory:
                    messagesSet = self.nodesMemory[self.nodeBoxId]
                    move = 0
                    for i in range(len(messagesSet)-1, -1, -1):
                        crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY - boxHeight + 14 + move)
                        layout.set_text(messagesSet[i])
                        move += 11
                        pg.show_layout(layout)
                else:
                    fg_color = pango.AttrForeground(55000, 0, 0, 0, -1)
                    attr.insert(fg_color)
                    layout.set_alignment(pango.ALIGN_CENTER)
                    layout.set_font_description(pango.FontDescription("Arial Bold 10"))
                    crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY - (boxHeight)/2 -5)
                    layout.set_text("Empty")
                    pg.show_layout(layout)

#                Headline
                crInfo.set_source_rgb(1, 1, 1)
                crInfo.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                crInfo.set_font_size(13)
                crInfo.move_to(self.nodeX - 1 - boxWidth + 2, self.nodeY+13-boxHeight)
                crInfo.show_text("Node {0}".format(self.nodeBoxId))
        else:
            if (self.nodeY - 1 - boxHeight) < 0: # overreach on the upper side
#                Box with dark header
                crInfo.set_source_rgba(0.8, 0.8, 0.8, 0.8)
                crInfo.rectangle(self.nodeX + 11, self.nodeY + self.nodeSize + 1, boxWidth, boxHeight)
                crInfo.fill()
                crInfo.set_source_rgba(0.5, 0.5, 0.5, 0.5)
                crInfo.rectangle(self.nodeX + 11, self.nodeY + self.nodeSize + 1, boxWidth, 16)
                crInfo.fill()

#                Pango text
                if self.nodeBoxId in self.nodesMemory:
                    messagesSet = self.nodesMemory[self.nodeBoxId]
                    move = 0
                    for i in range(len(messagesSet)-1, -1, -1):
                        crInfo.move_to(self.nodeX + 13, self.nodeY + self.nodeSize + 1 + 14 + move)
                        layout.set_text(messagesSet[i])
                        move += 11
                        pg.show_layout(layout)
                else:
                    fg_color = pango.AttrForeground(55000, 0, 0, 0, -1)
                    attr.insert(fg_color)
                    layout.set_alignment(pango.ALIGN_CENTER)
                    layout.set_font_description(pango.FontDescription("Arial Bold 10"))
                    crInfo.move_to(self.nodeX + 13, self.nodeY + (boxHeight)/2 + 5 + 1)
                    layout.set_text("Empty")
                    pg.show_layout(layout)

#                Headline
                crInfo.set_source_rgb(1, 1, 1)
                crInfo.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                crInfo.set_font_size(13)
                crInfo.move_to(self.nodeX + 13, self.nodeY + self.nodeSize + 1 +13)
                crInfo.show_text("Node {0}".format(self.nodeBoxId))
            else:#dont overreach on any side
#                Box with dark header
                crInfo.set_source_rgba(0.8, 0.8, 0.8, 0.8)
                crInfo.rectangle(self.nodeX + 11, self.nodeY - boxHeight - 1, boxWidth, boxHeight)
                crInfo.fill()
                crInfo.set_source_rgba(0.5, 0.5, 0.5, 0.5)
                crInfo.rectangle(self.nodeX + 11, self.nodeY - boxHeight - 1, boxWidth, 16)
                crInfo.fill()

#                Pango text
                if self.nodeBoxId in self.nodesMemory:
                    messagesSet = self.nodesMemory[self.nodeBoxId]
                    move = 0
                    for i in range(len(messagesSet)-1, -1, -1):
                        crInfo.move_to(self.nodeX + 13, self.nodeY - boxHeight + 14 + move)
                        layout.set_text(messagesSet[i])
                        move += 11
                        pg.show_layout(layout)
                else:
                    fg_color = pango.AttrForeground(55000, 0, 0, 0, -1)
                    attr.insert(fg_color)
                    layout.set_alignment(pango.ALIGN_CENTER)
                    layout.set_font_description(pango.FontDescription("Arial Bold 10"))
                    crInfo.move_to(self.nodeX + 13, self.nodeY - (boxHeight)/2 -5)
                    layout.set_text("Empty")
                    pg.show_layout(layout)

#                Headline
                crInfo.set_source_rgb(1, 1, 1)
                crInfo.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
                crInfo.set_font_size(13)
                crInfo.move_to(self.nodeX + 13, self.nodeY + 13 - boxHeight)
                crInfo.show_text("Node {0}".format(self.nodeBoxId))

        cr.set_source_surface(self.baseSurface)
        cr.paint()
        if self.com == True:
            cr.set_source_surface(self.comSurface)
            cr.paint()
        cr.set_source_surface(self.infoSurface)
        cr.paint()

#    This method gets the node specifications and starts drawInfoBox method.
    def showNodeInfo(self, widget, event):
        mouseX, mouseY = self.get_pointer()
        self.nodeX = -1
        self.nodeY = -1

        for node in self.allNodesList:
            nodeX, nodeY = node
            if ((nodeX - 1) <= mouseX) and (mouseX <= (nodeX + self.nodeSize + 1)):
                if ((nodeY - 1) <= mouseY) and (mouseY <= (nodeY + self.nodeSize + 1)):
                    self.nodeX = nodeX
                    self.nodeY = nodeY
                    self.nodeBoxId = self.allNodesList.index(node)

        if self.nodeWithBox != (self.nodeX, self.nodeY) and (self.nodeX, self.nodeY) != (-1, -1):
            self.nodeWithBox = (self.nodeX, self.nodeY)
            self.update(self.drawInfoBox)
            self.boxVisible = True
        else:
            self.nodeWithBox = (-1, -1)
            self.boxVisible = False
            if self.com == True:
                self.update(self.drawCommunicaton)
            else:
                self.update(self.drawAll)
            
#    This method gets nodeList from the Window class.
    def setList(self, list):
        self.nodeList = list
        self.update(self.drawAll)

#    This method redraw canvas.
    def update(self, method):
        self.currentDrawMethod = method
        self.window.invalidate_rect((0,0,self.area.width,self.area.height),False)

#    This method gets radius from the Window class.
    def setParameters(self, radius):
        self.radius = radius

#    This method generates topology files.
    def writeTopology(self, widget, data):
#        Inicialization of the topologyPy string with header for TOSSIM script
        topologyPy = "#! /usr/bin/python\nfrom TOSSIM import *\n\nt = Tossim([])\nr = t.radio()\n"
#        Inicialization of the topologyTxt string
        topologyTxt = "{0}\n".format(self.radius)
#        Insert nodes inicializations
        for node in range(self.numberOfMotes):
            topologyPy += "\nmote{0} = t.getNode({0})".format(node)
#        Generating topology sources
        for nodeTuple in self.nodeList:
            node0 = nodeTuple[0]
            node1 = nodeTuple[1]
            x0, y0 = node0
            x1, y1 = node1
            topologyTxt += "{0} {1} {2} {3}\n".format(x0, y0, x1, y1)
            if node1 != node0:
                gain = hypot(x1 - x0, y1 - y0) * 100 / self.radius
                topologyPy += "\nr.add({0}, {1}, -{2})".format(self.allNodesList.index((x0, y0)), self.allNodesList.index((x1, y1)), round(gain))
                topologyPy += "\nr.add({1}, {0}, -{2})".format(self.allNodesList.index((x0, y0)), self.allNodesList.index((x1, y1)), round(gain))

        dialog = gtk.FileChooserDialog("Save",
            None, gtk.FILE_CHOOSER_ACTION_SAVE,
            (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_SAVE, gtk.RESPONSE_OK))
        dialog.set_default_response(gtk.RESPONSE_OK)
        dialog.set_current_name("viz")
        response = dialog.run()
        if response == gtk.RESPONSE_OK:
    #        Writing to the file(script.py)
            f = open("{0}.py".format(dialog.get_filename()), "w")
            f.write(topologyPy)
            f.close()

    #        Writing to file(topology.txt)
            f = open("{0}.txt".format(dialog.get_filename()), "w")
            f.write(topologyTxt)
            f.close()
        dialog.destroy()

#    This method reads topology file.
    def readTopology(self, filePath):
#    def readTopology(self, widget, filePath):
        self.nodeList = []
        file = open(filePath, "rb")
        reader = csv.reader(file, delimiter=' ', quoting=csv.QUOTE_NONE)
        numberOfNodesSet = set()
        try:
            for row in reader:
                if len(row) == 1:
                    self.radius = int(row[0])
                else:

                    x0 = int(row[0])
                    y0 = int(row[1])
                    x1 = int(row[2])
                    y1 = int(row[3])

                    nodeTuple = [(x0, y0)]
                    nodeTuple.append((x1, y1))
                    numberOfNodesSet.add((x0, y0))
                    numberOfNodesSet.add((x1, y1))
                    self.nodeList.append(nodeTuple)
            self.numberOfMotes = len(numberOfNodesSet)
        except ValueError:
            md = gtk.MessageDialog(self.window,
            gtk.DIALOG_DESTROY_WITH_PARENT, gtk.MESSAGE_ERROR,
            gtk.BUTTONS_CLOSE, "Bad topology file.")
            md.run()
            md.destroy()
            file.close()
            
        file.close()
        self.update(self.drawAll)

#    This method saves path of the log file into tossimLogFilename variable.
    def setLogPath(self, path):
        self.tossimLogFilename = path

#    This method steps the log file.
    def stepTossimLog(self, widget, data):
        if not self.logOpend:
            self.tossimLogFile = open(self.tossimLogFilename, "r")
            self.nodesMemory = {}
            self.logOpend = True
        self.pauseTimer = False
        self.tossimLogFile.seek(self.possition)
        self.drawingTimer(self.tossimLogFile)

#    This method controls the pause of the simulation.
    def pauseTossimLog(self, widget, data):
        self.possition = self.tossimLogFile.tell()
        self.pauseTimer = True
        self.drawingTimer(self.tossimLogFile)

#    This method starts the timer for the simulation.
    def playTossimLog(self, widget, data):
        if not self.logOpend:
            self.tossimLogFile = open(self.tossimLogFilename, "r")
            self.nodesMemory = {}
            self.logOpend = True
        self.tossimLogFile.seek(self.possition)
        self.pauseTimer = False
        self.timer = gobject.timeout_add(self.speed, self.drawingTimer, self.tossimLogFile)

#    This method controls (re)drawing of the simulation.
    def drawingTimer(self, tossimLogFile):
        while True:
            self.com = True
            if self.pauseTimer == True:
                return False
            line = tossimLogFile.readline()
            if line == "":
                self.possition = 0
                self.currentDrawMethod = self.redrawToBase
                self.window.invalidate_rect((0,0,self.area.width,self.area.height),False)
                self.logOpend = False
                self.com = False
                tossimLogFile.close()
                return False
            else:
                self.possition = tossimLogFile.tell()
                lineList = [line]
                reader = csv.reader(lineList, delimiter=' ', quoting=csv.QUOTE_NONE)
                row = reader.next()
            try:
                if len(row) > 0:
                    if row[0] == "DEBUG":
                        nodeId = int(row[1].strip("():"))
    #            Sending paket:
                        if row[2] == "received":
                            if row[3] == "from":
                                if len(row) > 4:
                                    nodeTo = self.allNodesList[nodeId]
                                    nodeFrom = self.allNodesList[int(row[4])]
                                    self.comTuple = (nodeFrom, nodeTo)
                                    self.update(self.drawCommunicaton)
                                    self.window.process_updates(False)
                                    return True
                        elif row[2] == "sendDone":
                            if row[3] == "to":
                                if len(row) > 4:
                                    nodeFrom = self.allNodesList[nodeId]
				    if int(row[4]) < 255:
					nodeTo = self.allNodesList[int(row[4])]
		                        self.comTuple = (nodeFrom, nodeTo)
		                    	self.update(self.drawCommunicaton)
		                    	self.window.process_updates(False)
		                    return True

    #            Content of the packet:
                        if row[2] == "packet:":
                            print "packet"
                            packetList = []
                            for i in range(3, len(row)):
                                packetList.append(row[i])
                            packet = " ".join(packetList)
                            print "packet:", packet
                            if nodeId in self.nodesMemory:
                                memory = self.nodesMemory[nodeId]
                                if len(memory) > 9:
                                    memory.popleft()
                                    memory.append(packet)
                                    self.nodesMemory[nodeId] = memory
                                else:
                                    memory.append(packet)
                                    self.nodesMemory[nodeId] = memory
                            else:
                                memory = deque([packet])
                                self.nodesMemory[nodeId] = memory
                            if (self.boxVisible == True) and (self.nodeBoxId == nodeId):
                                self.update(self.drawInfoBox)
                                self.window.process_updates(False)

            except ValueError, e:
                print e
                self.logOpend = False
                self.com = False
                self.nodesMemory = {}
                tossimLogFile.close()
        
def run():
    window = Window()
    window.main()


if __name__ == "__main__":
    run()
